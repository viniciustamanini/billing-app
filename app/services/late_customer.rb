class LateCustomer
  def initialize(company)
    @company = company
  end

  def call
    @company.profiles
      .by_type('customer')
      .joins(:invoices)
      .where(invoices: { invoice_status: InvoiceStatus.overdue })
      .group('profiles.id')
      .order('MAX(invoices.due_date) ASC')
      .limit(8)
      .includes(:invoices)
  end
end
