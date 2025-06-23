require "test_helper"

class InvoiceVisibilityTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @customer_profile = profiles(:customer_one)
    @admin_profile = profiles(:admin_one)
    
    # Create invoice statuses if they don't exist
    @pending_status = InvoiceStatus.find_or_create_by(name: "pending")
    @issued_status = InvoiceStatus.find_or_create_by(name: "issued")
    @paid_status = InvoiceStatus.find_or_create_by(name: "paid")
    
    # Create renegotiation statuses if they don't exist
    @pending_reneg_status = RenegotiationStatus.find_or_create_by(name: "pending")
    @approved_reneg_status = RenegotiationStatus.find_or_create_by(name: "approved")
    @rejected_reneg_status = RenegotiationStatus.find_or_create_by(name: "rejected")
    @canceled_reneg_status = RenegotiationStatus.find_or_create_by(name: "canceled")
    
    # Create segment if it doesn't exist
    @segment = Segment.find_or_create_by(
      name: "Test Segment",
      company: @company,
      overdue_range: OverdueRange.find_or_create_by(
        name: "Test Range",
        days_from: 1,
        days_to: 30,
        company: @company
      )
    )
  end

  # Test 1: Rejected Renegotiations
  test "rejected renegotiation removes child invoices and restores original invoices" do
    # Create original invoice
    original_invoice = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @pending_status,
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 1000,
      paid_at: nil
    )

    # Create renegotiation
    renegotiation = Renegotiation.create!(
      renegotiation_status: @pending_reneg_status,
      proposed_by_profile: @admin_profile,
      customer_profile: @customer_profile,
      company: @company,
      segment: @segment,
      proposed_total_amount: 1200,
      proposed_due_date: Date.current + 30.days,
      installments: 3
    )

    # Link original invoice to renegotiation
    InvoiceRenegotiation.create!(
      invoice: original_invoice,
      renegotiation: renegotiation
    )

    # Create child invoices (installments)
    child_invoice_1 = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @issued_status,
      issued_date: Date.current,
      due_date: Date.current + 30.days,
      total_amount: 400,
      paid_at: nil,
      parent_renegotiation: renegotiation,
      installment_number: 1,
      installment_count: 3
    )

    child_invoice_2 = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @issued_status,
      issued_date: Date.current,
      due_date: Date.current + 60.days,
      total_amount: 400,
      paid_at: nil,
      parent_renegotiation: renegotiation,
      installment_number: 2,
      installment_count: 3
    )

    child_invoice_3 = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @issued_status,
      issued_date: Date.current,
      due_date: Date.current + 90.days,
      total_amount: 400,
      paid_at: nil,
      parent_renegotiation: renegotiation,
      installment_number: 3,
      installment_count: 3
    )

    # Before rejection: original invoice should NOT be in pending (has pending renegotiation)
    # Child invoices should NOT be in pending (they are child invoices)
    assert_not Invoice.pending.include?(original_invoice)
    assert_not Invoice.pending.include?(child_invoice_1)
    assert_not Invoice.pending.include?(child_invoice_2)
    assert_not Invoice.pending.include?(child_invoice_3)

    # Reject the renegotiation
    result = RenegotiationService::Reject.new(@customer_profile, renegotiation).call
    assert result.success?

    # After rejection: original invoice should be back in pending
    # Child invoices should be deleted
    assert Invoice.pending.include?(original_invoice)
    assert_not Invoice.exists?(child_invoice_1.id)
    assert_not Invoice.exists?(child_invoice_2.id)
    assert_not Invoice.exists?(child_invoice_3.id)
  end

  # Test 2: Approved Renegotiations
  test "approved renegotiation excludes original invoices and shows child invoices" do
    # Create original invoice
    original_invoice = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @pending_status,
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 1000,
      paid_at: nil
    )

    # Create renegotiation
    renegotiation = Renegotiation.create!(
      renegotiation_status: @pending_reneg_status,
      proposed_by_profile: @admin_profile,
      customer_profile: @customer_profile,
      company: @company,
      segment: @segment,
      proposed_total_amount: 1200,
      proposed_due_date: Date.current + 30.days,
      installments: 3
    )

    # Link original invoice to renegotiation
    InvoiceRenegotiation.create!(
      invoice: original_invoice,
      renegotiation: renegotiation
    )

    # Create child invoices (installments)
    child_invoice_1 = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @issued_status,
      issued_date: Date.current,
      due_date: Date.current + 30.days,
      total_amount: 400,
      paid_at: nil,
      parent_renegotiation: renegotiation,
      installment_number: 1,
      installment_count: 3
    )

    child_invoice_2 = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @issued_status,
      issued_date: Date.current,
      due_date: Date.current + 60.days,
      total_amount: 400,
      paid_at: nil,
      parent_renegotiation: renegotiation,
      installment_number: 2,
      installment_count: 3
    )

    child_invoice_3 = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @issued_status,
      issued_date: Date.current,
      due_date: Date.current + 90.days,
      total_amount: 400,
      paid_at: nil,
      parent_renegotiation: renegotiation,
      installment_number: 3,
      installment_count: 3
    )

    # Before approval: original invoice should NOT be in pending (has pending renegotiation)
    # Child invoices should NOT be in pending (they are child invoices)
    assert_not Invoice.pending.include?(original_invoice)
    assert_not Invoice.pending.include?(child_invoice_1)
    assert_not Invoice.pending.include?(child_invoice_2)
    assert_not Invoice.pending.include?(child_invoice_3)

    # Approve the renegotiation
    result = RenegotiationService::Accept.new(@customer_profile, renegotiation).call
    assert result.success?

    # After approval: original invoice should NOT be in pending (has approved renegotiation)
    # Child invoices should be in pending (they are now active)
    assert_not Invoice.pending.include?(original_invoice)
    assert Invoice.pending.include?(child_invoice_1)
    assert Invoice.pending.include?(child_invoice_2)
    assert Invoice.pending.include?(child_invoice_3)
  end

  # Test 3: Edge Case - Multiple Renegotiations for Same Invoice
  test "multiple renegotiations for same invoice handle visibility correctly" do
    # Create original invoice
    original_invoice = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @pending_status,
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 1000,
      paid_at: nil
    )

    # Create first renegotiation (rejected)
    first_renegotiation = Renegotiation.create!(
      renegotiation_status: @rejected_reneg_status,
      proposed_by_profile: @admin_profile,
      customer_profile: @customer_profile,
      company: @company,
      segment: @segment,
      proposed_total_amount: 1200,
      proposed_due_date: Date.current + 30.days,
      installments: 3,
      decision_date: Date.current
    )

    # Link original invoice to first renegotiation
    InvoiceRenegotiation.create!(
      invoice: original_invoice,
      renegotiation: first_renegotiation
    )

    # Create second renegotiation (pending)
    second_renegotiation = Renegotiation.create!(
      renegotiation_status: @pending_reneg_status,
      proposed_by_profile: @admin_profile,
      customer_profile: @customer_profile,
      company: @company,
      segment: @segment,
      proposed_total_amount: 1100,
      proposed_due_date: Date.current + 60.days,
      installments: 2
    )

    # Link original invoice to second renegotiation
    InvoiceRenegotiation.create!(
      invoice: original_invoice,
      renegotiation: second_renegotiation
    )

    # Original invoice should be in pending (has pending renegotiation, but no approved)
    assert Invoice.pending.include?(original_invoice)

    # Approve the second renegotiation
    result = RenegotiationService::Accept.new(@customer_profile, second_renegotiation).call
    assert result.success?

    # After approval: original invoice should NOT be in pending (has approved renegotiation)
    assert_not Invoice.pending.include?(original_invoice)
  end

  # Test 4: Status Transitions
  test "invoice visibility toggles correctly with renegotiation status transitions" do
    # Create original invoice
    original_invoice = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @pending_status,
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 1000,
      paid_at: nil
    )

    # Create renegotiation
    renegotiation = Renegotiation.create!(
      renegotiation_status: @pending_reneg_status,
      proposed_by_profile: @admin_profile,
      customer_profile: @customer_profile,
      company: @company,
      segment: @segment,
      proposed_total_amount: 1200,
      proposed_due_date: Date.current + 30.days,
      installments: 3
    )

    # Link original invoice to renegotiation
    InvoiceRenegotiation.create!(
      invoice: original_invoice,
      renegotiation: renegotiation
    )

    # Initial state: pending renegotiation, invoice should be in pending
    assert Invoice.pending.include?(original_invoice)

    # Transition to approved
    renegotiation.update!(renegotiation_status: @approved_reneg_status)
    assert_not Invoice.pending.include?(original_invoice)

    # Transition back to pending
    renegotiation.update!(renegotiation_status: @pending_reneg_status)
    assert Invoice.pending.include?(original_invoice)

    # Transition to rejected
    renegotiation.update!(renegotiation_status: @rejected_reneg_status)
    assert Invoice.pending.include?(original_invoice)

    # Transition to canceled
    renegotiation.update!(renegotiation_status: @canceled_reneg_status)
    assert Invoice.pending.include?(original_invoice)
  end

  # Test 5: Child Invoice Visibility
  test "child invoices visibility based on parent renegotiation status" do
    # Create renegotiation
    renegotiation = Renegotiation.create!(
      renegotiation_status: @pending_reneg_status,
      proposed_by_profile: @admin_profile,
      customer_profile: @customer_profile,
      company: @company,
      segment: @segment,
      proposed_total_amount: 1200,
      proposed_due_date: Date.current + 30.days,
      installments: 3
    )

    # Create child invoice
    child_invoice = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @issued_status,
      issued_date: Date.current,
      due_date: Date.current + 30.days,
      total_amount: 400,
      paid_at: nil,
      parent_renegotiation: renegotiation,
      installment_number: 1,
      installment_count: 3
    )

    # With pending parent: child should NOT be in pending
    assert_not Invoice.pending.include?(child_invoice)

    # With approved parent: child should be in pending
    renegotiation.update!(renegotiation_status: @approved_reneg_status)
    assert Invoice.pending.include?(child_invoice)

    # With rejected parent: child should NOT be in pending
    renegotiation.update!(renegotiation_status: @rejected_reneg_status)
    assert_not Invoice.pending.include?(child_invoice)
  end

  # Test 6: Dashboard Integration
  test "dashboard shows correct pending invoices based on renegotiation status" do
    # Create original invoice
    original_invoice = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @pending_status,
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 1000,
      paid_at: nil
    )

    # Create renegotiation
    renegotiation = Renegotiation.create!(
      renegotiation_status: @pending_reneg_status,
      proposed_by_profile: @admin_profile,
      customer_profile: @customer_profile,
      company: @company,
      segment: @segment,
      proposed_total_amount: 1200,
      proposed_due_date: Date.current + 30.days,
      installments: 3
    )

    # Link original invoice to renegotiation
    InvoiceRenegotiation.create!(
      invoice: original_invoice,
      renegotiation: renegotiation
    )

    # Create child invoices
    child_invoice_1 = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @issued_status,
      issued_date: Date.current,
      due_date: Date.current + 30.days,
      total_amount: 400,
      paid_at: nil,
      parent_renegotiation: renegotiation,
      installment_number: 1,
      installment_count: 3
    )

    child_invoice_2 = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @issued_status,
      issued_date: Date.current,
      due_date: Date.current + 60.days,
      total_amount: 400,
      paid_at: nil,
      parent_renegotiation: renegotiation,
      installment_number: 2,
      installment_count: 3
    )

    # Before approval: only original invoice should be in pending
    pending_invoices = Invoice.where(profile: @customer_profile).pending
    assert pending_invoices.include?(original_invoice)
    assert_not pending_invoices.include?(child_invoice_1)
    assert_not pending_invoices.include?(child_invoice_2)

    # Approve renegotiation
    result = RenegotiationService::Accept.new(@customer_profile, renegotiation).call
    assert result.success?

    # After approval: only child invoices should be in pending
    pending_invoices = Invoice.where(profile: @customer_profile).pending
    assert_not pending_invoices.include?(original_invoice)
    assert pending_invoices.include?(child_invoice_1)
    assert pending_invoices.include?(child_invoice_2)
  end

  # Test 7: Turbo/Real-time Updates
  test "invoice visibility updates immediately without page reload" do
    # Create original invoice
    original_invoice = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @pending_status,
      issued_date: Date.current,
      due_date: Date.current,
      total_amount: 1000,
      paid_at: nil
    )

    # Create renegotiation
    renegotiation = Renegotiation.create!(
      renegotiation_status: @pending_reneg_status,
      proposed_by_profile: @admin_profile,
      customer_profile: @customer_profile,
      company: @company,
      segment: @segment,
      proposed_total_amount: 1200,
      proposed_due_date: Date.current + 30.days,
      installments: 3
    )

    # Link original invoice to renegotiation
    InvoiceRenegotiation.create!(
      invoice: original_invoice,
      renegotiation: renegotiation
    )

    # Create child invoices
    child_invoice_1 = Invoice.create!(
      profile: @customer_profile,
      company: @company,
      invoice_status: @issued_status,
      issued_date: Date.current,
      due_date: Date.current + 30.days,
      total_amount: 400,
      paid_at: nil,
      parent_renegotiation: renegotiation,
      installment_number: 1,
      installment_count: 3
    )

    # Verify initial state
    assert Invoice.pending.include?(original_invoice)
    assert_not Invoice.pending.include?(child_invoice_1)

    # Simulate real-time approval (no page reload)
    renegotiation.update!(renegotiation_status: @approved_reneg_status)

    # Verify immediate update
    assert_not Invoice.pending.include?(original_invoice)
    assert Invoice.pending.include?(child_invoice_1)

    # Simulate real-time rejection
    renegotiation.update!(renegotiation_status: @rejected_reneg_status)

    # Verify immediate update
    assert Invoice.pending.include?(original_invoice)
    assert_not Invoice.exists?(child_invoice_1.id) # Child invoices are deleted on rejection
  end
end 