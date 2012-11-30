
class RolesController < ApplicationController
  filter_resource_access
  def index
    @roles = Role.all
    @new_role = Role.new
  end

  def create
    @new_role = Role.update_roles(params[:role][:roles])
    @roles = Role.all
    redirect_to index
  end
end
