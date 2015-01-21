require 'test_helper'

class OrderControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get search" do
    get :search
    assert_response :success
  end

  test "should get place_order" do
    get :place_order
    assert_response :success
  end

  test "should get review_results" do
    get :review_results
    assert_response :success
  end

  test "should get print_results" do
    get :print_results
    assert_response :success
  end

  test "should get print_order" do
    get :print_order
    assert_response :success
  end

end
