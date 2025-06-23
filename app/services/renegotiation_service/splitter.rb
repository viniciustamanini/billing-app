module RenegotiationService
  class Splitter
    def initialize(renegotiation)
      @renegotiation = renegotiation
    end

    def call
      # Activate all child invoices by changing their status from draft to issued
      @renegotiation.child_invoices.each do |invoice|
        invoice.update!(
          invoice_status: InvoiceStatus.issued,
          issued_date: Date.current
        )
      end
    end
  end
end

