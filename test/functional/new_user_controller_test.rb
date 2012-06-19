require 'test_helper'

class NewUserControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get create" do
    assert_difference('User.count', 1) do
      post :create, user: {:login => "new_user", :password => "123456", :password_confirmation => "123456", :email => "new_user@yopmail.com"}
    end
    assert_redirected_to root_url
  end

end
