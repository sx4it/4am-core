class HostTplsController < ApplicationController
  # GET /host_tpls
  # GET /host_tpls.json
  def index
    @host_tpls = HostTpl.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @host_tpls }
    end
  end

  # GET /host_tpls/1
  # GET /host_tpls/1.json
  def show
    @host_tpl = HostTpl.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @host_tpl }
    end
  end

  # GET /host_tpls/new
  # GET /host_tpls/new.json
  def new
    @host_tpl = HostTpl.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @host_tpl }
    end
  end

  # GET /host_tpls/1/edit
  def edit
    @host_tpl = HostTpl.find(params[:id])
  end

  # POST /host_tpls
  # POST /host_tpls.json
  def create
    @host_tpl = HostTpl.new(params[:host_tpl])

    respond_to do |format|
      if @host_tpl.save
        format.html { redirect_to @host_tpl, notice: 'Host tpl was successfully created.' }
        format.json { render json: @host_tpl, status: :created, location: @host_tpl }
      else
        format.html { render action: "new" }
        format.json { render json: @host_tpl.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /host_tpls/1
  # PUT /host_tpls/1.json
  def update
    @host_tpl = HostTpl.find(params[:id])

    respond_to do |format|
      if @host_tpl.update_attributes(params[:host_tpl])
        format.html { redirect_to @host_tpl, notice: 'Host tpl was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @host_tpl.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /host_tpls/1
  # DELETE /host_tpls/1.json
  def destroy
    @host_tpl = HostTpl.find(params[:id])
    @host_tpl.destroy

    respond_to do |format|
      format.html { redirect_to host_tpls_url }
      format.json { head :no_content }
    end
  end
end
