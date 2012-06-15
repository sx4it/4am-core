class CmdController < ApplicationController
  before_filter :has_permission

  def index
    @cmd = Cmd.all(params[:host_id])

    redirect_to host_path(params[:host_id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @host }
    end
  end

  def show
    @cmd = Cmd.find(params[:host_id], params[:id])
    redirect_to host_path(params[:host_id])
  end

  def clear
    Cmd.clear(params[:host_id])
    redirect_to host_path(params[:host_id])
  end

  def new
    @cmd = Cmd.exec(params[:host_id], params[:command_id], @current_user)
    redirect_to host_path(params[:host_id])
  end

  def edit
  end

  def create
  end

  def update
    @cmd = Cmd.find(params[:host_id], params[:id])
    @cmd.stop
    redirect_to host_path(params[:host_id])
  end

  def destroy
    @cmd = Cmd.find(params[:host_id], params[:id])
    @cmd.destroy
    redirect_to host_path(params[:host_id])
  end

  private
  def has_permission
    @host = Host.find params[:host_id]
    unless permitted_to? :view, @host
      flash[:error] = "Sorry, you are not allowed to do that."
      redirect_to root_url
    end
  end

end
