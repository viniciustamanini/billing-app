require "test_helper"

class CustomerDashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get customer_dashboard_index_url
    assert_response :success
  end
end
