require "test_helper"

class SegmentMatcherTest < ActiveSupport::TestCase
  def setup
    @company = companies(:one)
    @customer_profile = profiles(:customer_one)
    @renegotiation_amount = 1000.0
  end

  test "calculates overdue days correctly" do
    # Create an overdue invoice
    overdue_invoice = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      total_amount: 500.0,
      due_date: 30.days.ago,
      issued_date: 60.days.ago,
      invoice_status: invoice_statuses(:overdue)
    )

    matcher = SegmentMatcher.new(@company, @customer_profile, @renegotiation_amount)
    result = matcher.call

    assert result.success?
    assert_equal 30, result.overdue_days
  end

  test "returns 0 overdue days when no overdue invoices" do
    # Create a non-overdue invoice
    Invoice.create!(
      profile: @customer_profile,
      company: @company,
      total_amount: 500.0,
      due_date: 30.days.from_now,
      issued_date: Date.current,
      invoice_status: invoice_statuses(:pending)
    )

    matcher = SegmentMatcher.new(@company, @customer_profile, @renegotiation_amount)
    result = matcher.call

    assert result.success?
    assert_equal 0, result.overdue_days
  end

  test "finds applicable segments based on overdue days and amount" do
    # Create overdue range
    overdue_range = OverdueRange.create!(
      company: @company,
      name: "30-60 days",
      days_from: 30,
      days_to: 60,
      active: true
    )

    # Create segment matching the criteria
    segment = Segment.create!(
      company: @company,
      overdue_range: overdue_range,
      name: "Segment A",
      debt_min: 500.0,
      debt_max: 2000.0,
      active: true,
      interest_rate: 5.0,
      interest_strategy: "flat_late_fee"
    )

    # Create an overdue invoice
    Invoice.create!(
      profile: @customer_profile,
      company: @company,
      total_amount: 500.0,
      due_date: 45.days.ago,
      issued_date: 75.days.ago,
      invoice_status: invoice_statuses(:overdue)
    )

    matcher = SegmentMatcher.new(@company, @customer_profile, @renegotiation_amount)
    result = matcher.call

    assert result.success?
    assert_equal 45, result.overdue_days
    assert_includes result.segments, segment
  end

  test "returns empty segments when no matching criteria" do
    # Create overdue range that doesn't match
    overdue_range = OverdueRange.create!(
      company: @company,
      name: "90-120 days",
      days_from: 90,
      days_to: 120,
      active: true
    )

    # Create segment with amount range that doesn't match
    segment = Segment.create!(
      company: @company,
      overdue_range: overdue_range,
      name: "Segment B",
      debt_min: 2000.0,
      debt_max: 5000.0,
      active: true,
      interest_rate: 5.0,
      interest_strategy: "flat_late_fee"
    )

    # Create an overdue invoice (30 days overdue)
    Invoice.create!(
      profile: @customer_profile,
      company: @company,
      total_amount: 500.0,
      due_date: 30.days.ago,
      issued_date: 60.days.ago,
      invoice_status: invoice_statuses(:overdue)
    )

    matcher = SegmentMatcher.new(@company, @customer_profile, @renegotiation_amount)
    result = matcher.call

    assert result.success?
    assert_equal 30, result.overdue_days
    assert_empty result.segments
  end
end 