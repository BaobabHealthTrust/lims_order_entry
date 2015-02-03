require 'test_helper'

class LabProcessingControllerTest < ActionController::TestCase
  test "should get receive_samples" do
    get :receive_samples
    assert_response :success
  end

  test "should get enter_results" do
    get :enter_results
    assert_response :success
  end

  test "should get verify_results" do
    get :verify_results
    assert_response :success
  end

  test "should get dispose_samples" do
    get :dispose_samples
    assert_response :success
  end

end
