class HostAclsController < ApplicationController
  filter_resource_access
  def index
    @acls = HostAcl.all
    @new_acl = AclForm.new
  end

  def create
    @new_acl = AclForm.new params[:acl_form]
    if @new_acl.valid?
      puts @new_acl.inspect
      HostAcl.create :users => @new_acl.user, :hosts => @new_acl.host, :acl_type => @new_acl.type
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
    @acl = HostAcl.find params[:id]
    @acl.destroy
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
