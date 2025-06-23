class CustomerRenegotiationsController < ApplicationController
  include Pagy::Backend
  
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_customer_profile
  before_action :set_invoice, only: [:new_proposal, :create_proposal]
  before_action :set_renegotiation, only: [:show, :accept, :reject]

  # Customer can view their renegotiations
  def index
    @renegotiations = @customer_profile.renegotiations
      .includes(:proposed_by_profile, :renegotiation_status, :company)
      .order(created_at: :desc)
  end

  # Customer can view a specific renegotiation
  def show
    unless @renegotiation.customer_profile == @customer_profile
      redirect_to company_customer_renegotiations_path(@company), 
                  alert: "Renegociação não encontrada"
      return
    end
  end

  # Customer can propose a new renegotiation
  def new_proposal
    # Check if invoice is eligible for renegotiation
    unless @invoice.can_be_renegotiated?
      redirect_to company_profile_customer_dashboard_path(@company, @customer_profile), 
                  alert: "Esta fatura não pode ser renegociada"
      return
    end

    # Check if there's already a pending renegotiation for this invoice
    if @invoice.has_pending_renegotiation?
      redirect_to company_profile_customer_dashboard_path(@company, @customer_profile), 
                  alert: "Já existe uma renegociação pendente para esta fatura"
      return
    end

    # Get applicable segments for the customer
    segment_matcher = SegmentMatcher.new(@company, @customer_profile, @invoice.total_amount)
    result = segment_matcher.call

    if result.success? && result.segments.any?
      @segments = result.segments
      @overdue_days = result.overdue_days
    else
      redirect_to company_profile_customer_dashboard_path(@company, @customer_profile), 
                  alert: "Nenhum segmento aplicável encontrado para renegociação"
      return
    end

    # Calculate renegotiation options
    proposed_due_date = params[:proposed_due_date].presence || Date.current
    @offers_by_segment = @segments.index_with do |segment|
      RenegotiationService::Calculator.all_offers(
        invoice: @invoice,
        segment: segment,
        proposed_due_date: proposed_due_date
      )
    end
  end

  # Customer creates a renegotiation proposal
  def create_proposal
    # Validate invoice eligibility
    unless @invoice.can_be_renegotiated?
      render_error("Esta fatura não pode ser renegociada") and return
    end

    # Check for existing pending renegotiation
    if @invoice.has_pending_renegotiation?
      render_error("Já existe uma renegociação pendente para esta fatura") and return
    end

    # Get segment
    segment = @company.segments.find(customer_renegotiation_params[:segment_id])
    
    # Calculate renegotiation terms
    calc = RenegotiationService::Calculator.call(
      invoice: @invoice,
      segment: segment,
      params: customer_renegotiation_params.slice(:strategy, :installments, :proposed_due_date)
    )

    if calc.error
      render_error(calc.error) and return
    end

    # Create the renegotiation proposal
    result = RenegotiationService::Propose.new(
      @customer_profile, # Customer is the proposer
      invoice: @invoice,
      segment: segment,
      params: {
        proposed_total_amount: calc.proposed_total_amount,
        proposed_due_date: customer_renegotiation_params[:proposed_due_date],
        installments: calc.schedule.size,
        reason: customer_renegotiation_params[:reason] || "Proposta do cliente"
      }
    ).call

    if result.success?
      redirect_to company_customer_renegotiations_path(@company), 
                  notice: "Proposta de renegociação enviada com sucesso!"
    else
      render_error(result.error)
    end
  end

  # Customer accepts a renegotiation proposal
  def accept
    # Validate that this renegotiation belongs to the customer
    unless @renegotiation.customer_profile == @customer_profile
      redirect_to company_customer_renegotiations_path(@company), 
                  alert: "Renegociação não encontrada"
      return
    end

    # Validate that customer can accept (they should be the customer, not the proposer)
    unless @renegotiation.customer_profile == @customer_profile && 
           @renegotiation.proposed_by_profile != @customer_profile
      redirect_to company_customer_renegotiation_path(@company, @renegotiation), 
                  alert: "Você não pode aceitar esta renegociação"
      return
    end

    result = RenegotiationService::Accept.new(@customer_profile, @renegotiation).call

    if result.success?
      redirect_to company_customer_renegotiation_path(@company, @renegotiation), 
                  notice: "Renegociação aceita com sucesso!"
    else
      redirect_to company_customer_renegotiation_path(@company, @renegotiation), 
                  alert: result.error
    end
  end

  # Customer rejects a renegotiation proposal
  def reject
    # Validate that this renegotiation belongs to the customer
    unless @renegotiation.customer_profile == @customer_profile
      redirect_to company_customer_renegotiations_path(@company), 
                  alert: "Renegociação não encontrada"
      return
    end

    # Validate that customer can reject (they should be the customer, not the proposer)
    unless @renegotiation.customer_profile == @customer_profile && 
           @renegotiation.proposed_by_profile != @customer_profile
      redirect_to company_customer_renegotiation_path(@company, @renegotiation), 
                  alert: "Você não pode rejeitar esta renegociação"
      return
    end

    result = RenegotiationService::Reject.new(@customer_profile, @renegotiation).call

    if result.success?
      redirect_to company_customer_renegotiation_path(@company, @renegotiation), 
                  notice: "Renegociação rejeitada"
    else
      redirect_to company_customer_renegotiation_path(@company, @renegotiation), 
                  alert: result.error
    end
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_customer_profile
    # Find the customer profile for the current user in this company
    @customer_profile = @company.profiles
      .joins(:user)
      .by_type("customer")
      .find_by!(user: current_user)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Perfil de cliente não encontrado"
  end

  def set_invoice
    @invoice = @company.invoices.find(params[:invoice_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to company_profile_customer_dashboard_path(@company, @customer_profile), 
                alert: "Fatura não encontrada"
  end

  def set_renegotiation
    @renegotiation = @company.renegotiations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to company_customer_renegotiations_path(@company), 
                alert: "Renegociação não encontrada"
  end

  def customer_renegotiation_params
    params.permit(
      :strategy,
      :installments,
      :reason,
      :proposed_due_date,
      :segment_id
    )
  end

  def render_error(message)
    respond_to do |format|
      format.html do
        flash.now[:error] = message
        render turbo_stream: turbo_stream.update("flash", 
          partial: "shared/toast", 
          locals: { message: message, icon: "error" }
        )
      end
      format.json { render json: { error: message }, status: :unprocessable_entity }
    end
  end
end 