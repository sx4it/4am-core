require 'test_helper'

class KeysControllerTest < ActionController::TestCase
  setup do
    @key = create :key
  end

  test "should get index" do
    get :index, id: @key.user.to_param
    assert_response :success
    assert_not_nil assigns(:keys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create key" do
    assert_difference('Key.count') do
      post :create, key: {:ssh_key => "ssh-rsa key key"}
    end

    assert_redirected_to keys_user_path(@admin)
  end

  test "should show key" do
    get :show, id: @key.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @key.to_param
    assert_response :success
  end

  test "should update key" do
    put :update, id: @key.to_param, key: @key.attributes
    assert_redirected_to keys_user_path(@key.user)
  end

  test "should destroy key" do
    assert_difference('Key.count', -1) do
      delete :destroy, id: @key.to_param
    end

    assert_redirected_to keys_user_path(@key.user)
  end
end
