class ChartDataService
  def initialize(company, dates)
    @company = company
    @dates = dates
  end

  def call
    @dates.index_with { |date| data_for_date(date) }
  end

  private

  def data_for_date(date)
    invoices_for_date = @company.invoices.where(due_date: date)
    received = @company.invoices.where(paid_at: date.all_day).sum(:total_amount)
    expected = invoices_for_date.sum(:total_amount)
    {
      expected: expected,
      received: received
    }
  end
end 