require 'test_helper'

class MachineTplsControllerTest < ActionController::TestCase
  setup do
    @machine_tpl = machine_tpls(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:machine_tpls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create machine_tpl" do
    assert_difference('MachineTpl.count') do
      post :create, machine_tpl: @machine_tpl.attributes
    end

    assert_redirected_to machine_tpl_path(assigns(:machine_tpl))
  end

  test "should show machine_tpl" do
    get :show, id: @machine_tpl
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @machine_tpl
    assert_response :success
  end

  test "should update machine_tpl" do
    put :update, id: @machine_tpl, machine_tpl: @machine_tpl.attributes
    assert_redirected_to machine_tpl_path(assigns(:machine_tpl))
  end

  test "should destroy machine_tpl" do
    assert_difference('MachineTpl.count', -1) do
      delete :destroy, id: @machine_tpl
    end

    assert_redirected_to machine_tpls_path
  end
end
