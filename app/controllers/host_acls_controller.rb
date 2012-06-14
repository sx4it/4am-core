class HostAclsController < ApplicationController
  def index
    @acls = HostAcl.all
    @hosts = Host.all
    @host_groups = HostGroup.all
    @new_acl = HostAcl.new
  end

  def create
    flash[:error] = params
    redisplay_acl
  end

  def destroy
    redisplay_acl
  end
  private

  def redisplay_acl
    respond_to do |format|
      format.html { redirect_to host_acls_path }
      format.js {
        @acls = HostAcl.all
        render :redisplay_roles
      }
   end
  end
end
