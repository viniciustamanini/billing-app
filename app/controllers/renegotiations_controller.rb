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

    @offers_by_segment = segments.index_with do |seg|
      RenegotiationService::Calculator.all_offers(
        invoice:  @invoice,
        segment:  seg
      )
    end

    respond_to do |format|
      format.json { render json: @offers_by_segment }
      format.html
    end
  end

  def render_offer
    offer = params[:offer].deep_symbolize_keys
    render partial: "offer_card", locals: { offer: offer }
  end

  def create
    segment = @invoice.profile.segment
    calc    = RenegotiationService::Calculator.call(
                invoice: @invoice,
                segment: segment,
                params:  renegotiation_params.slice(:strategy, :installments)
              )

    return render json: { error: calc.error }, status: :unprocessable_entity if calc.error

    result = RenegotiationService::Propose.new(
      current_profile,
      invoice: @invoice,
      params: {
        proposed_total_amount: calc.proposed_total_amount,
        proposed_due_date: calc.proposed_due_date,
        installments: calc.installments,
        schedule: calc.schedule,
        reason: params[:reason]
      }
    ).call

    if result.success?
      render json: { id: result.renegotiation.id }, status: :created
    else
      render json: { error: result.error }, status: :unprocessable_entity
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
    params.permit(:strategy, :installments, :company_id, :reason, :profile_id)
  end
end
