class HostAclsController < ApplicationController
  filter_resource_access
  def index
    @acls = HostAcl.all
    @new_acl = AclForm.new
  end

  def create
    flash[:error] = params[:acl_form]
    @new_acl = AclForm.new params[:acl_form]
    if @new_acl.valid?
      redisplay_acl
    else
      @acls = HostAcl.all
      respond_to do |format|
        format.html { render :index }
        format.js { render :redisplay_acl }
      end
    end
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
        @new_acl = AclForm.new
        render :redisplay_acl
      }
   end
  end
end
