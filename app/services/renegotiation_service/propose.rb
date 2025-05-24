module RenegotiationService
  class Propose
    Result = Struct.new(:success?, :renegotiation, :error)

    def initialize(proposer, invoice:, params:)
      @proposer = proposer
      @invoice = invoice
      @params = params
    end

    def call
      ActiveRecord::Base.transaction do
        reneg = Renegotiation.create!(
          company: @invoice.company,
          proposed_by_profile: @proposer,
          customer_profile: @invoice.profile,
          proposed_total_amount: @params[:proposed_total_amount],
          proposed_due_date: @params[:proposed_due_date],
          reason: @params[:reason],
          installments: @params[:installments],
          renegotiation_status: RenegotiationStatus.pending
        )

        total = BigDecimal(@params[:proposed_total_amount].to_s)
        count = @params[:installments].to_i.clamp(1, 60)
        per_installment = (total / count).round(2)

        @params[:schedule].each_with_index do |due_date, index|
          invoice = Invoice.create!(
            profile: @invoice.profile,
            company: @invoice.company,
            issued_date: Date.current,
            total_amount: per_installment,
            due_date: due_date,
            original_due_date: due_date,
            parent_renegotiation_id: reneg.id,
            installment_number: index + 1,
            installment_count: count,
            invoice_status: InvoiceStatus.issued
          )

          invoice.invoice_items.create!(
            description: "Parcela gerada via renegociação",
            quantity: 1,
            unit_price: per_installment,
          )
        end

        Result.new(true, reneg, nil)
      end
    rescue StandardError => e
      Result.new(false, nil, e.message)
    end
  end
end
