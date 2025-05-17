require "test_helper"

class OverdueRangesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get overdue_ranges_index_url
    assert_response :success
  end

  test "should get new" do
    get overdue_ranges_new_url
    assert_response :success
  end

  test "should get create" do
    get overdue_ranges_create_url
    assert_response :success
  end

  test "should get edit" do
    get overdue_ranges_edit_url
    assert_response :success
  end

  test "should get update" do
    get overdue_ranges_update_url
    assert_response :success
  end
end
