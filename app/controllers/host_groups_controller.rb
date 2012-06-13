
class HostGroupsController < ApplicationController
  # GET /host_groups
  # GET /host_groups.json
  def index
    @host_groups = HostGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @host_groups }
    end
  end

  # GET /host_groups/1
  # GET /host_groups/1.json
  def show
    @host_group = HostGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @host_group }
    end
  end

  # GET /host_groups/new
  # GET /host_groups/new.json
  def new
    @host_group = HostGroup.new
    @hosts = Host.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @host_group }
    end
  end

  def add_host
    @host_group = HostGroup.find(params[:host_group_id])
    @host = Host.find(params[:host_id])
    @host_group.host << @host
    redirect_to edit_host_group_path(@host_group)
  end

  def del_host
    @host_group = HostGroup.find(params[:host_group_id])
    @host = Host.find(params[:host_id])
    @host_group.host.delete @host
    redirect_to edit_host_group_path(@host_group)
  end

  # GET /host_groups/1/edit
  def edit
    @host_group = HostGroup.find(params[:id])
    @hosts = Host.all
  end

  # POST /host_groups
  # POST /host_groups.json
  def create
    @host_group = HostGroup.new(params[:host_group])

    respond_to do |format|
      if @host_group.save
        format.html { redirect_to @host_group, notice: 'Host group was successfully created.' }
        format.json { render json: @host_group, status: :created, location: @host_group }
      else
        format.html { render action: "new" }
        format.json { render json: @host_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /host_groups/1
  # PUT /host_groups/1.json
  def update
    @host_group = HostGroup.find(params[:id])

    respond_to do |format|
      if @host_group.update_attributes(params[:host_group])
        format.html { redirect_to @host_group, notice: 'Host group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @host_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /host_groups/1
  # DELETE /host_groups/1.json
  def destroy
    @host_group = HostGroup.find(params[:id])
    @host_group.destroy

    respond_to do |format|
      format.html { redirect_to host_groups_url }
      format.json { head :no_content }
    end
  end
end
