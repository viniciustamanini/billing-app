require "test_helper"

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @company = companies(:one)
    @profile = profiles(:customer_one)
    @invoice = invoices(:one)
    sign_in @user
  end

  test "should get index" do
    get invoices_index_url
    assert_response :success
  end

  test "should get new" do
    get invoices_new_url
    assert_response :success
  end

  test "should get create" do
    get invoices_create_url
    assert_response :success
  end

  test "should get show" do
    get company_profile_invoice_path(@company, @profile, @invoice)
    assert_response :success
  end

  test "should mark invoice as paid" do
    # Ensure invoice is not already paid
    @invoice.update!(paid_at: nil)
    
    assert_nil @invoice.paid_at
    
    patch mark_as_paid_company_profile_invoice_path(@company, @profile, @invoice)
    
    @invoice.reload
    assert_not_nil @invoice.paid_at
    assert_redirected_to company_profile_invoice_path(@company, @profile, @invoice)
    assert_equal "Fatura marcada como paga com sucesso!", flash[:notice]
  end

  test "should not mark already paid invoice as paid" do
    # Set invoice as already paid
    @invoice.update!(paid_at: 1.day.ago)
    
    patch mark_as_paid_company_profile_invoice_path(@company, @profile, @invoice)
    
    assert_redirected_to company_profile_invoice_path(@company, @profile, @invoice)
    assert_equal "Esta fatura já foi marcada como paga", flash[:alert]
  end
end
