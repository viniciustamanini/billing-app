require "test_helper"

class RenegotiationsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get renegotiations_create_url
    assert_response :success
  end
end
