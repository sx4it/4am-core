
class UserGroupsController < ApplicationController
  filter_resource_access
  # GET /user_groups
  # GET /user_groups.json
  def index
    @user_groups = UserGroup.with_permissions_to(:show)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_groups }
    end
  end

  # GET /user_groups/1
  # GET /user_groups/1.json
  def show
    @user_group = UserGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_group }
    end
  end

  # GET /user_groups/new
  # GET /user_groups/new.json
  def new
    @user_group = UserGroup.new
    @users = User.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_group }
    end
  end

  def add_user
    @user_group = UserGroup.find(params[:id])
    @user = User.find(params[:user_id])
    @user_group.user << @user
    Cmd::Action.add_user_in_group @user_group, @user
    redirect_to edit_user_group_path(@user_group)
  end

  def del_user
    @user_group = UserGroup.find(params[:id])
    @user = User.find(params[:user_id])
    @user_group.user.delete @user
    Cmd::Action.del_user_in_group @user_group, @user
    redirect_to edit_user_group_path(@user_group)
  end


  # GET /user_groups/1/edit
  def edit
    @user_group = UserGroup.find(params[:id])
    @users = User.all
  end

  # POST /user_groups
  # POST /user_groups.json
  def create
    @user_group = UserGroup.new(params[:user_group])

    respond_to do |format|
      if @user_group.save
        format.html { redirect_to @user_group, notice: 'User group was successfully created.' }
        format.json { render json: @user_group, status: :created, location: @user_group }
      else
        @users = User.all
        format.html { render action: "new" }
        format.json { render json: @user_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_groups/1
  # PUT /user_groups/1.json
  def update
    @user_group = UserGroup.find(params[:id])

    respond_to do |format|
      if @user_group.update_attributes(params[:user_group])
        Cmd::Action.update_user_group @user_group
        format.html { redirect_to @user_group, notice: 'User group was successfully updated.' }
        format.json { head :no_content }
      else
        @users = User.all
        format.html { render action: "edit" }
        format.json { render json: @user_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_groups/1
  # DELETE /user_groups/1.json
  def destroy
    @user_group = UserGroup.find(params[:id])
    Cmd::Action.delete_user_group @user_group
    @user_group.destroy
    respond_to do |format|
      format.html { redirect_to user_groups_url }
      format.json { head :no_content }
    end
  end
end
