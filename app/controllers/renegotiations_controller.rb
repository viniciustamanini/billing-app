class RenegotiationsController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!
  before_action :set_invoice, except: %i[index]
  before_action :set_company
  before_action :set_renegotiation, only: %i[show cancel accept reject]

  def index
    @query = params[:search].to_s.strip
    @status_id = params[:status_id].presence

    scope = @company.renegotiations
      .includes(:customer_profile)
      .order(created_at: :desc)

    scope = scope.where(renegotiation_status_id: @status_id) if @status_id.present? && @status_id != "all"
    @pagy, @renegotiations = pagy(scope, items: 10)
  end

  def options
    # Use enhanced segmentation logic
    segment_matcher = SegmentMatcher.new(@company, @invoice.profile, @invoice.total_amount)
    result = segment_matcher.call

    if result.success?
      segments = result.segments
      @overdue_days = result.overdue_days
    else
      # Fallback to all active segments if segmentation fails
      segments = @company.segments.active
      @overdue_days = 0
      flash.now[:warning] = "Erro na segmentação: #{result.error}. Usando todos os segmentos ativos."
    end

    proposed_due_date = params[:proposed_due_date].presence || Date.current

    @offers_by_segment = segments.index_with do |seg|
      RenegotiationService::Calculator.all_offers(
        invoice: @invoice,
        segment: seg,
        proposed_due_date: proposed_due_date
      )
    end

    respond_to do |format|
      format.json { render json: @offers_by_segment }
      format.html
    end
  end

  def recalculate
    segment = @company.segments.find(params[:segment_id])
    installments = params[:installments].to_i.clamp(1, segment.max_installments)
    proposed_due_date = params[:proposed_due_date].presence || Date.current.to_s

    calc = RenegotiationService::Calculator.call(
      invoice: @invoice,
      segment: segment,
      params: {
        strategy: segment.interest_strategy || @company.default_interest_strategy,
        installments: installments,
        proposed_due_date: proposed_due_date
      }
    )

    if calc.error
      render turbo_stream: turbo_stream.update("flash", partial: "shared/toast", locals: { message: calc.error, icon: "error" })
    else
      offer = {
        strategy: segment.interest_strategy || @company.default_interest_strategy,
        installments: installments,
        schedule: calc.schedule,
        proposed_total_amount: calc.proposed_total_amount,
        segment_id: segment.id
      }
      render partial: "offer_card", locals: { offer: offer, company: @company, invoice: @invoice }
    end
  end

  def render_offer
    offer = params[:offer].deep_symbolize_keys
    render partial: "offer_card", locals: { offer: offer }
  end

  def create
    # Handle segment selection
    if renegotiation_params[:segment_id].present?
      segment = @company.segments.find(renegotiation_params[:segment_id])
    else
      # Use enhanced segmentation logic to find applicable segment
      segment_matcher = SegmentMatcher.new(@company, @invoice.profile, @invoice.total_amount)
      result = segment_matcher.call
      
      if result.success? && result.segments.any?
        segment = result.segments.first
      else
        render_error("Nenhum segmento aplicável encontrado para este cliente") and return
      end
    end

    calc = RenegotiationService::Calculator.call(
      invoice: @invoice,
      segment: segment,
      params: renegotiation_params.slice(:strategy, :installments, :proposed_due_date)
    )

    if calc.error
      render_error(calc.error) and return
    end

    result = RenegotiationService::Propose.new(
      current_profile,
      invoice: @invoice,
      segment: segment,
      params: {
        proposed_total_amount: calc.proposed_total_amount,
        proposed_due_date: renegotiation_params[:proposed_due_date],
        installments: calc.schedule.size,
        reason: renegotiation_params[:reason]
      }
    ).call

    if result.success?
      redirect_to company_renegotiations_path(@company), notice: "Renegociação proposta com sucesso!"
    else
      render_error(result.error)
    end
  end

  def show
    @original_invoices = @renegotiation.invoice_renegotiations.map(&:invoice)
    @generated_invoices = @renegotiation.child_invoices
  end

  def cancel
    result = RenegotiationService::Cancel.new(current_profile, @renegotiation).call
    redirect_to company_renegotiation_path(@company, @renegotiation), notice: result.success? ? "Renegociação cancelada." : result.error
  end

  def accept
    result = RenegotiationService::Accept.new(current_profile, @renegotiation).call
    redirect_to company_renegotiation_path(@company, @renegotiation), notice: result.success? ? "Renegociação aceita." : result.error
  end

  def reject
    result = RenegotiationService::Reject.new(current_profile, @renegotiation).call
    redirect_to company_renegotiation_path(@company, @renegotiation), notice: result.success? ? "Renegociação rejeitada." : result.error
  end

  private

  def set_renegotiation
    @renegotiation = @company.renegotiations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to company_renegotiations_path(@company), alert: "Renegociação não encontrada."
  end

  def set_invoice
    @invoice = @company.invoices.find(params[:invoice_id]) if params[:invoice_id]
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def renegotiation_params
    params.permit(
      :strategy,
      :installments,
      :company_id,
      :reason,
      :profile_id,
      :proposed_due_date,
      :proposed_total_amount,
      :invoice_id,
      :segment_id
    )
  end

  def render_error(message)
    respond_to do |format|
      format.html do
        flash.now[:error] = message
        render turbo_stream: turbo_stream.update("flash", partial: "shared/toast", locals: { message: message, icon: "error" })
      end
      format.json { render json: { error: message }, status: :unprocessable_entity }
    end
  end
end
