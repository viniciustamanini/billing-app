class RenegotiationsController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!
  before_action :set_invoice, except: %i[index]
  before_action :set_company

  def index
    @query = params[:search].to_s.strip
    @status_id = params[:status_id].presence

    scope = @company.renegotiations
      .includes(:customer_profile)
      .order(created_at: :desc)

    if @status_id.present? && @status_id != "all"
      scope = scope.where(renegotiation_status_id: @status_id)
    end

    @pagy, @renegotiations = pagy(scope, items: 10)
  end

  def options
    customer_segment = @invoice.profile.segment
    segments = @company.segments.active
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
    installments = params[:installments].to_i
    proposed_due_date = params[:proposed_due_date].presence || Date.current.to_s

    installments = installments.clamp(1, segment.max_installments)

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
        total_amount: calc.total_amount
      }
      render partial: "offer_card", locals: { offer: offer, company: @company, invoice: @invoice }
    end
  end

  def render_offer
    offer = params[:offer].deep_symbolize_keys
    render partial: "offer_card", locals: { offer: offer }
  end

  def create
    segment = @invoice.profile.segment
    calc = RenegotiationService::Calculator.call(
      invoice: @invoice,
      segment: segment,
      params:  renegotiation_params.slice(:strategy, :installments)
    )

    if calc.error
      respond_to do |format|
        format.html do
          flash.now[:error] = calc.error
          render turbo_stream: turbo_stream.update("flash", partial: "shared/toast", locals: { message: calc.error, icon: "error" })
        end
        format.json { render json: { error: calc.error }, status: :unprocessable_entity }
      end
      return
    end

    result = RenegotiationService::Propose.new(
      current_profile,
      invoice: @invoice,
      params: {
        total_amount: params[:total_amount] || calc.total_amount,
        proposed_due_date: params[:proposed_due_date],
        installments: calc.schedule.size,
        reason: params[:reason],
        schedule: calc.schedule
      }
    ).call

    respond_to do |format|
      if result.success?
        format.html { redirect_to company_renegotiations_path(@company), notice: "Renegociação proposta com sucesso!" }
        format.json { render json: { id: result.renegotiation.id }, status: :created }
      else
        format.html do
          flash.now[:error] = result.error
          render turbo_stream: turbo_stream.update("flash", partial: "shared/toast", locals: { message: result.error, icon: "error" })
        end
        format.json { render json: { error: result.error }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:invoice_id])
  end

  def calculate_offers(invoice, segment)
    [
      build_offer(invoice, segment, strategy: "settlement_discount"),
      build_offer(invoice, segment, strategy: "flat_late_fee", installments: 3),
      build_offer(invoice, segment, strategy: "flat_late_fee", installments: 6)
    ]
  end

  def build_offer(invoice, segment, strategy:, installments: 1)
    calc = RenegotiationService::Calculator.call(
             invoice: invoice,
             segment: segment,
             params:  { strategy: strategy, installments: installments }
           )
    {
      code: "#{strategy}-#{installments}",
      strategy: strategy,
      installments: (calc.schedule || []).size,
      schedule: (calc.schedule || []),
      total_amount: calc.total_amount
    }
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def renegotiation_params
    params.permit(:strategy, :installments, :company_id, :reason, :profile_id, :proposed_due_date)
  end
end
