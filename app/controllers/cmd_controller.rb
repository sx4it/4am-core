class CmdController < ApplicationController
  before_filter :has_permission

  def index
    @cmd = Cmd.all(params[:host_id])

    respond_to do |format|
      format.html # show.html.erb
      { redirect_to host_path(params[:host_id]) }
      format.json { render json: @cmd }
    end
  end

  def show
    @cmd = Cmd.find(params[:host_id], params[:id])
    redirect_to host_path(params[:host_id])
  end

  def clear
    Cmd.clear(params[:host_id])
    redisplay
  end

  def new
    @cmd = Cmd.exec(params[:host_id], params[:command_id], @current_user)
    redisplay
  end

  def refresh
    redisplay
  end

  def create
  end

  def update
    @cmd = Cmd.find(params[:host_id], params[:id])
    @cmd.stop
    redisplay
    #redirect_to host_path(params[:host_id])
  end

  def destroy
    @cmd = Cmd.find(params[:host_id], params[:id])
    @cmd.stop
    @cmd.destroy
    redisplay
  end

  private

  def redisplay
    respond_to do |format|
      format.html {
        redirect_to host_path(params[:host_id])
        }
      format.js {
        @host = Host.find params[:host_id]
        @old_command = Cmd.all(params[:host_id])
        render 'commands/old_commands_list'
      }
   end
  end

  def has_permission
    @host = Host.find params[:host_id]
    unless permitted_to? :view, @host
      flash[:error] = "Sorry, you are not allowed to do that."
      redirect_to root_url
    end
  end

end
