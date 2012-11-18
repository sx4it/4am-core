class UsersController < ApplicationController
  filter_resource_access

  helper_method :sort_column, :sort_direction

  # GET /users
  # GET /users.json
  def index
    @user = User.first
    @users = User.with_permissions_to(:show).search(params[:search], params[:page]).paginate(per_page: 10, page: params[:page]).order(sort_column + ' ' + sort_direction)
    #@users = User.page(params[:page])
    #@users = User.paginate(per_page: 10, :page => params[:page])


    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @users }
    end

  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  def reset_api_token
    @user = User.find(params[:id])
    flash[:notice] = "Api token reseted."
    @user.reset_single_access_token
    @user.save
    respond_to do |format|
      format.html { redirect_to @user }
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
    @roles = Role.all
    @groups = UserGroup.all
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @roles = Role.all
    @groups = UserGroup.all
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_path(@user), notice: 'User was successfully created.' }
        format.json { render json: user_path(@user), status: :created, location: @user }
      else
        format.html { 
          @roles = Role.all
          @groups = UserGroup.all
          render action: "new" }
        format.json { render json: @users.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to user_path(@user), notice: 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html {
          @roles = Role.all
          @groups = UserGroup.all
          render action: "edit"
        }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "login"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
