class MachineTplsController < ApplicationController
  # GET /machine_tpls
  # GET /machine_tpls.json
  def index
    @machine_tpls = MachineTpl.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @machine_tpls }
    end
  end

  # GET /machine_tpls/1
  # GET /machine_tpls/1.json
  def show
    @machine_tpl = MachineTpl.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @machine_tpl }
    end
  end

  # GET /machine_tpls/new
  # GET /machine_tpls/new.json
  def new
    @machine_tpl = MachineTpl.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @machine_tpl }
    end
  end

  # GET /machine_tpls/1/edit
  def edit
    @machine_tpl = MachineTpl.find(params[:id])
  end

  # POST /machine_tpls
  # POST /machine_tpls.json
  def create
    @machine_tpl = MachineTpl.new(params[:machine_tpl])

    respond_to do |format|
      if @machine_tpl.save
        format.html { redirect_to @machine_tpl, notice: 'Machine tpl was successfully created.' }
        format.json { render json: @machine_tpl, status: :created, location: @machine_tpl }
      else
        format.html { render action: "new" }
        format.json { render json: @machine_tpl.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /machine_tpls/1
  # PUT /machine_tpls/1.json
  def update
    @machine_tpl = MachineTpl.find(params[:id])

    respond_to do |format|
      if @machine_tpl.update_attributes(params[:machine_tpl])
        format.html { redirect_to @machine_tpl, notice: 'Machine tpl was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @machine_tpl.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /machine_tpls/1
  # DELETE /machine_tpls/1.json
  def destroy
    @machine_tpl = MachineTpl.find(params[:id])
    @machine_tpl.destroy

    respond_to do |format|
      format.html { redirect_to machine_tpls_url }
      format.json { head :no_content }
    end
  end
end
