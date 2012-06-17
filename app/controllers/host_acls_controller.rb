class HostAclsController < ApplicationController
  attr_accessor :errors
  filter_resource_access
  def index
    @acls = HostAcl.all
    @new_acl = AclForm.new
  end

  def create
    @new_acl = AclForm.new params[:acl_form]
    @new_acl.valid?
    h = HostAcl.new(:users => @new_acl.user, :hosts => @new_acl.host, :acl_type => @new_acl.type)
    if @new_acl.valid? and h.valid?
        @errors = nil
        h.save
        redisplay_acl
    else
      @errors = h.errors.dup unless h.valid?
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
