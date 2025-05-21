class RenegotiationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice
  before_action :set_company

  def options
    segment = @invoice.profile.segment
    @offers  = calculate_offers(@invoice, segment)

    respond_to do |format|
      format.html
      format.json { render json: @offers }
    end
  end

  def create
    segment = @invoice.profile.segment
    calc    = Renegotiation::Calculator.call(
                invoice: @invoice,
                segment: segment,
                params:  renegotiation_params.slice(:strategy, :installments)
              )

    return render json: { error: calc.error }, status: :unprocessable_entity if calc.error

    result = Renegotiation::Propose.new(
               proposer: current_profile,
               invoice:  @invoice,
               params:   {
                 total_amount: calc.total_amount,
                 due_date:     calc.schedule.first,
                 installments: calc.schedule.size,
                 reason:       params[:reason]
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
    params.permit(:strategy, :installments)
  end
end
