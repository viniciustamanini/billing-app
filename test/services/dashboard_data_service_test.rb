require "test_helper"

class DashboardDataServiceTest < ActiveSupport::TestCase
  def setup
    @company = companies(:one)
    @service = DashboardDataService.new(@company)
  end

  test "returns receipts data with real values" do
    result = @service.call
    
    assert_includes result, :receipts
    assert_includes result[:receipts], :total
    assert_includes result[:receipts], :delta
    assert_includes result[:receipts], :on_time
    assert_includes result[:receipts], :overdue
    
    # Values should be numeric
    assert_kind_of Numeric, result[:receipts][:total]
    assert_kind_of String, result[:receipts][:delta]
    assert_kind_of Numeric, result[:receipts][:on_time]
    assert_kind_of Numeric, result[:receipts][:overdue]
  end

  test "returns collections data with real values" do
    result = @service.call
    
    assert_includes result, :collections
    assert_includes result[:collections], :total
    assert_includes result[:collections], :delta
    assert_includes result[:collections], :notifications_sent
    assert_includes result[:collections], :recovered_overdue
    assert_includes result[:collections], :early_payments
    
    # Values should be numeric
    assert_kind_of Numeric, result[:collections][:total]
    assert_kind_of String, result[:collections][:delta]
    assert_kind_of Integer, result[:collections][:notifications_sent]
    assert_kind_of Numeric, result[:collections][:recovered_overdue]
    assert_kind_of Numeric, result[:collections][:early_payments]
  end

  test "returns renegotiations data with real values" do
    result = @service.call
    
    assert_includes result, :renegotiations
    assert_includes result[:renegotiations], :total
    assert_includes result[:renegotiations], :approved
    assert_includes result[:renegotiations], :percentage
    
    # Values should be numeric
    assert_kind_of Integer, result[:renegotiations][:total]
    assert_kind_of Integer, result[:renegotiations][:approved]
    assert_kind_of Numeric, result[:renegotiations][:percentage]
    
    # Percentage should be between 0 and 100
    assert result[:renegotiations][:percentage] >= 0
    assert result[:renegotiations][:percentage] <= 100
  end

  test "returns overdue percentage with real values" do
    result = @service.call
    
    assert_includes result, :overdue_percentage
    assert_kind_of Numeric, result[:overdue_percentage]
    assert result[:overdue_percentage] >= 0
    assert result[:overdue_percentage] <= 100
  end

  test "returns payment bars data with real values" do
    result = @service.call
    
    assert_includes result, :payment_bars
    assert_kind_of Array, result[:payment_bars]
    
    result[:payment_bars].each do |bar|
      assert_includes bar, :label
      assert_includes bar, :percentage
      assert_includes bar, :total
      assert_includes bar, :paid
      
      assert_kind_of String, bar[:label]
      assert_kind_of Integer, bar[:percentage]
      assert_kind_of Integer, bar[:total]
      assert_kind_of Integer, bar[:paid]
      
      assert bar[:percentage] >= 0
      assert bar[:percentage] <= 100
    end
  end

  test "returns chart data with real values" do
    result = @service.call
    
    assert_includes result, :chart_data
    assert_kind_of Hash, result[:chart_data]
    
    result[:chart_data].each do |date, data|
      assert_includes data, :expected
      assert_includes data, :received
      
      assert_kind_of Numeric, data[:expected]
      assert_kind_of Numeric, data[:received]
    end
  end

  test "returns late customers data with real values" do
    result = @service.call
    
    assert_includes result, :late_customers
    assert_kind_of ActiveRecord::Relation, result[:late_customers]
    assert result[:late_customers].count <= 8
  end

  test "handles empty data gracefully" do
    # Create a new company with no data
    empty_company = Company.create!(name: "Empty Company", email: "empty@example.com")
    service = DashboardDataService.new(empty_company)
    result = service.call
    
    # Should return zero values instead of errors
    assert_equal 0, result[:receipts][:total]
    assert_equal "0%", result[:receipts][:delta]
    assert_equal 0, result[:collections][:total]
    assert_equal "0%", result[:collections][:delta]
    assert_equal 0, result[:renegotiations][:total]
    assert_equal 0, result[:renegotiations][:percentage]
    assert_equal 0, result[:overdue_percentage]
    assert_empty result[:payment_bars]
    assert_empty result[:chart_data]
    assert_empty result[:late_customers]
  end
end 