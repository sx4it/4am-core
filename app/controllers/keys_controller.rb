class KeysController < ApplicationController
  filter_resource_access
  # GET /keys
  # GET /keys.json
  def index
    @keys = Key.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @keys }
    end
  end

  # GET /keys/1
  # GET /keys/1.json
  def show
    @key = Key.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @key }
    end
  end

  # GET /keys/new
  # GET /keys/new.json
  def new
    @key = Key.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @key }
    end
  end

  # GET /keys/1/edit
  def edit
    @key = Key.find(params[:id])
  end

  # POST /keys
  # POST /keys.json
  def create
    @key = Key.new do |k|
      k.ssh_key = params[:key][:ssh_key]
      k.name = params[:key][:name]
      k.user = current_user
    end

    respond_to do |format|
      if @key.save
        format.html { redirect_to keys_user_path(current_user), notice: 'Key was successfully added.' }
        format.json { render json: key_path(@key), status: :created, location: @key }
      else
        format.html { render action: "new" }
        format.json { render json: @key.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /keys/1
  # PUT /keys/1.json
  def update
    @key = Key.find(params[:id])

    respond_to do |format|
      if @key.update_attributes(params[:key])
        format.html {
          redirect_to key_path(@key), notice: 'Key was successfully updated.'
        }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keys/1
  # DELETE /keys/1.json
  def destroy
    @key = Key.find(params[:id])
    @user = @key.user
    @key.destroy

    # FIXME Should be removed from hosts

    respond_to do |format|
      format.html { 
        if @user == current_user
          redirect_to keys_user_path(current_user)
        else
          redirect_to keys_url
        end}
      format.json { head :ok }
    end
  end
end
