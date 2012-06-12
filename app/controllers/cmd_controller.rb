class CmdController < ApplicationController
  def index
    @cmd = Cmd.all(params[:machine_id])

    redirect_to machine_path(params[:machine_id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @machine }
    end
  end

  def show
    @cmd = Cmd.find(params[:machine_id], params[:id])
    redirect_to machine_path(params[:machine_id])
  end

  def clear
    Cmd.clear(params[:machine_id])
    redirect_to machine_path(params[:machine_id])
  end

  def new
    @cmd = Cmd.exec(params[:machine_id], params[:command_id], @current_user)
    redirect_to machine_path(params[:machine_id])
  end

  def edit
  end

  def create
  end

  def update
    @cmd = Cmd.find(params[:machine_id], params[:id])
    @cmd.stop
    redirect_to machine_path(params[:machine_id])
  end

  def destroy
    @cmd = Cmd.find(params[:machine_id], params[:id])
    @cmd.destroy
    redirect_to machine_path(params[:machine_id])
  end
end
