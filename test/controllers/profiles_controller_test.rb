require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get choose" do
    get profiles_choose_url
    assert_response :success
  end
end
