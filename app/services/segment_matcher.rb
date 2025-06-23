class SegmentMatcher
  Result = Struct.new(:success?, :segments, :overdue_days, :error, keyword_init: true)

  def initialize(company, customer_profile, renegotiation_amount)
    @company = company
    @customer_profile = customer_profile
    @renegotiation_amount = renegotiation_amount
  end

  def call
    overdue_days = calculate_overdue_days
    segments = find_applicable_segments(overdue_days)
    
    Result.new(
      success?: true,
      segments: segments,
      overdue_days: overdue_days,
      error: nil
    )
  rescue StandardError => e
    Result.new(
      success?: false,
      segments: [],
      overdue_days: 0,
      error: e.message
    )
  end

  private

  def calculate_overdue_days
    # Find the most overdue invoice for the customer
    most_overdue_invoice = @customer_profile.invoices
      .overdue
      .where(paid_at: nil)
      .order(:due_date)
      .first

    return 0 unless most_overdue_invoice

    # Calculate days overdue
    (Date.current - most_overdue_invoice.due_date).to_i
  end

  def find_applicable_segments(overdue_days)
    @company.segments.for_renegotiation(overdue_days, @renegotiation_amount)
  end
end 