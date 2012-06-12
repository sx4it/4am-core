require 'test_helper'

class HostGroupsControllerTest < ActionController::TestCase
  setup do
    @host_group = host_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:host_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create host_group" do
    assert_difference('HostGroup.count') do
      post :create, host_group: { name: @host_group.name }
    end

    assert_redirected_to host_group_path(assigns(:host_group))
  end

  test "should show host_group" do
    get :show, id: @host_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @host_group
    assert_response :success
  end

  test "should update host_group" do
    put :update, id: @host_group, host_group: { name: @host_group.name }
    assert_redirected_to host_group_path(assigns(:host_group))
  end

  test "should destroy host_group" do
    assert_difference('HostGroup.count', -1) do
      delete :destroy, id: @host_group
    end

    assert_redirected_to host_groups_path
  end
end
