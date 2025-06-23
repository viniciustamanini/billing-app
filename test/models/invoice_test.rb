require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @customer_profile = profiles(:customer_one)
  end

  test "pending scope excludes paid invoices" do
    # Create a paid invoice
    paid_invoice = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: invoice_statuses(:one),
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 100,
      paid_at: Date.current
    )

    assert_not Invoice.pending.include?(paid_invoice)
  end

  test "pending scope includes unpaid invoices without renegotiations" do
    # Create an unpaid invoice without renegotiations
    unpaid_invoice = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: invoice_statuses(:one),
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 100,
      paid_at: nil
    )

    assert Invoice.pending.include?(unpaid_invoice)
  end

  test "pending scope excludes invoices with approved renegotiations" do
    # Create an unpaid invoice with an approved renegotiation
    invoice_with_approved = invoices(:two) # This invoice has an approved renegotiation via fixture
    
    assert_not Invoice.pending.include?(invoice_with_approved)
  end

  test "pending scope includes invoices with pending renegotiations" do
    # Create an unpaid invoice with a pending renegotiation
    invoice_with_pending = invoices(:one) # This invoice has a pending renegotiation via fixture
    
    assert Invoice.pending.include?(invoice_with_pending)
  end

  test "pending scope includes invoices with rejected renegotiations" do
    # Create an unpaid invoice with a rejected renegotiation
    invoice_with_rejected = invoices(:one) # This invoice also has a rejected renegotiation via fixture
    
    assert Invoice.pending.include?(invoice_with_rejected)
  end

  test "pending scope includes invoices with canceled renegotiations" do
    # Create an unpaid invoice with a canceled renegotiation
    canceled_renegotiation = renegotiations(:approved_renegotiation)
    canceled_renegotiation.update!(renegotiation_status: renegotiation_statuses(:canceled))
    
    invoice_with_canceled = invoices(:two)
    
    assert Invoice.pending.include?(invoice_with_canceled)
  end

  test "pending scope handles invoices with multiple renegotiations correctly" do
    # Create an invoice with both pending and approved renegotiations
    invoice = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: invoice_statuses(:one),
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 100,
      paid_at: nil
    )

    # Add a pending renegotiation
    pending_renegotiation = renegotiations(:pending_renegotiation)
    invoice.invoice_renegotiations.create!(renegotiation: pending_renegotiation)

    # Add an approved renegotiation
    approved_renegotiation = renegotiations(:approved_renegotiation)
    invoice.invoice_renegotiations.create!(renegotiation: approved_renegotiation)

    # Should be excluded because it has an approved renegotiation
    assert_not Invoice.pending.include?(invoice)
  end

  test "without_approved_renegotiations scope works independently" do
    # Test the scope directly
    invoices_without_approved = Invoice.without_approved_renegotiations
    
    # Should include invoices with no renegotiations
    assert invoices_without_approved.include?(invoices(:one))
    
    # Should exclude invoices with approved renegotiations
    assert_not invoices_without_approved.include?(invoices(:two))
  end

  test "pending scope calculates correct total amount" do
    # Create multiple invoices with different statuses
    unpaid_no_renegotiation = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: invoice_statuses(:one),
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 100,
      paid_at: nil
    )

    unpaid_with_pending = invoices(:one) # Has pending renegotiation
    
    unpaid_with_approved = invoices(:two) # Has approved renegotiation

    pending_total = Invoice.pending.sum(:total_amount)
    
    # Should include: unpaid_no_renegotiation (100) + unpaid_with_pending (9.99)
    # Should exclude: unpaid_with_approved (9.99)
    expected_total = 100 + 9.99
    
    assert_in_delta expected_total, pending_total, 0.01
  end

  test "pending scope works with complex queries" do
    # Test that the scope works with other scopes
    overdue_pending = Invoice.overdue.pending
    
    # Should not include invoices with approved renegotiations
    assert_not overdue_pending.include?(invoices(:two))
    
    # Should include overdue invoices without approved renegotiations
    assert overdue_pending.include?(invoices(:one))
  end

  test "pending scope excludes child invoices whose parent renegotiation is rejected" do
    # Create a rejected renegotiation
    rejected_reneg = Renegotiation.create!(
      renegotiation_status: renegotiation_statuses(:rejected),
      proposed_by_profile: profiles(:customer_one),
      customer_profile: profiles(:customer_one),
      company: companies(:one),
      segment: segments(:one),
      proposed_total_amount: 100,
      proposed_due_date: Date.current,
      decision_date: Date.current
    )
    child_invoice = Invoice.create!(
      profile: profiles(:customer_one),
      company: companies(:one),
      invoice_status: invoice_statuses(:pending),
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 100,
      paid_at: nil,
      parent_renegotiation: rejected_reneg
    )
    assert_not Invoice.pending.include?(child_invoice)
  end

  test "pending scope excludes child invoices whose parent renegotiation is approved" do
    approved_reneg = Renegotiation.create!(
      renegotiation_status: renegotiation_statuses(:approved),
      proposed_by_profile: profiles(:customer_one),
      customer_profile: profiles(:customer_one),
      company: companies(:one),
      segment: segments(:one),
      proposed_total_amount: 100,
      proposed_due_date: Date.current,
      decision_date: Date.current
    )
    child_invoice = Invoice.create!(
      profile: profiles(:customer_one),
      company: companies(:one),
      invoice_status: invoice_statuses(:pending),
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 100,
      paid_at: nil,
      parent_renegotiation: approved_reneg
    )
    assert_not Invoice.pending.include?(child_invoice)
  end

  test "pending scope includes invoices not tied to approved or rejected renegotiations" do
    invoice = Invoice.create!(
      profile: profiles(:customer_one),
      company: companies(:one),
      invoice_status: invoice_statuses(:pending),
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 100,
      paid_at: nil
    )
    assert Invoice.pending.include?(invoice)
  end
end
