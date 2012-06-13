
class RolesController < ApplicationController
  def index
    @roles = Role.all
    @new_role = Role.new
  end

  def create
    @new_role = Role.create(params[:role])
    if @new_role.id.nil?
      @roles = Role.all
      respond_to do |format|
        format.html { render :index }
        format.js { render :redisplay_form }
      end
    else
      redisplay_roles
    end
  end

  def destroy
    Role.find(params[:id]).destroy
    redisplay_roles
  end

  private

  def redisplay_roles
    respond_to do |format|
      format.html { redirect_to roles_path }
      format.js {
        @roles = Role.all
        @new_role = Role.new
        render :redisplay_roles
      }
   end
  end
end
