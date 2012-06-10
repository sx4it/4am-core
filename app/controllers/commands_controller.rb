
class CommandsController < ApplicationController
  # GET /commands
  # GET /commands.json
  def index
    @commands = Command.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @commands }
    end
  end

  # GET /commands/1
  # GET /commands/1.json
  def show
    @command = Command.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @command }
    end
  end

  # GET /commands/1/exec
  # GET /commands/1/exec.json
  def exec
    @machine = Machine.find(params[:machine_id])
    @command = Command.find(params[:command_id])

    @machine.execute(@command)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: [@command, @machine] }
    end
  end

  # GET /commands/new
  # GET /commands/new.json
  def new
    @command = Command.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @command }
    end
  end

  # GET /commands/1/edit
  def edit
    @command = Command.find(params[:id])
  end

  # POST /commands
  # POST /commands.json
  def create
    @command = Command.new(params[:command])

    respond_to do |format|
      if @command.save
        format.html { redirect_to @command, notice: 'Command was successfully created.' }
        format.json { render json: @command, status: :created, location: @command }
      else
        format.html { render action: "new" }
        format.json { render json: @command.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /commands/1
  # PUT /commands/1.json
  def update
    @command = Command.find(params[:id])

    respond_to do |format|
      if @command.update_attributes(params[:command])
        format.html { redirect_to @command, notice: 'Command was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @command.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /commands/1
  # DELETE /commands/1.json
  def destroy
    @command = Command.find(params[:id])
    @command.destroy

    respond_to do |format|
      format.html { redirect_to commands_url }
      format.json { head :no_content }
    end
  end
end
