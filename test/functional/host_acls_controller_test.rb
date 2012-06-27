require 'test_helper'

class HostAclsControllerTest < ActionController::TestCase
  setup do
    @host_acl = create(:host_acl)
  end
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get create" do
    assert_difference('HostAcl.count', 1) do
      h = create :host, :name => "host_acl"
      u = create :user, :login => "login_acl"
      post :create, :acl_form => {:type => "Read", :user_id => u.id, :host_id => h.id, :user_type => u.type, :host_type => h.type}
    end
    assert_redirected_to host_acls_path
  end

  test "should get delete" do
    assert_difference('HostAcl.count', -1) do
      delete :destroy, id: @host_acl
    end
    assert_redirected_to host_acls_path
  end

end
