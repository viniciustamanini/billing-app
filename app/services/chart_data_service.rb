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
    expected = rand(10000..50000)
    received = rand(0..expected)
    
    {
      expected: expected,
      received: received
    }
  end
end 