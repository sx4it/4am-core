class KeysController < ApplicationController
  filter_resource_access
  # GET /keys
  # GET /keys.json
  def index
    @keys = User.find(params[:id]).keys

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @keys }
    end
  end

  # GET /keys/1
  # GET /keys/1.json
  def show
    @keys = Key.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @keys }
    end
  end

  # GET /keys/new
  def new
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
      if params[:key][:name] && params[:key][:name] != ""
        k.name_pref = true
        k.name = params[:key][:name]
    else
        k.name_pref = false
      end
      k.user = @current_user
    end

    respond_to do |format|
      if @key.save
        format.html { redirect_to keys_user_path(@key.user), notice: 'Key was successfully added.' }
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
    @key.ssh_key = params[:key][:ssh_key]
    if params[:key][:name] && params[:key][:name] != ""
        @key.name_pref = true
        @key.name = params[:key][:name]
    else
        @key.name_pref = false
    end

    respond_to do |format|
      if @key.save
        format.html { redirect_to keys_user_path(@key.user), notice: 'Key was successfully updated.' }
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
    key = Key.find(params[:id])
    if key
      key.destroy
      # FIXME Should be removed from hosts
      respond_to do |format|
        format.html { redirect_to keys_user_path(@key.user), notice: 'Key was successfully deleted.' }
        format.json { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to root, notice: 'Key not found.' }
        format.json { render status: :not_found }
      end
    end
  end

  # GET /keys/1/x509
  def x509
    pubkey = Key.find(params[:id])
    send_data pubkey.x509.to_pem,
              :filename => "4am-#{@key.user.login}.crt",
              :type => "application/x-x509-ca-cert"
  end

  # GET /keys/1/pkcs12/new
  def pkcs12_new
  end

  # POST /keys/1/pkcs12
  def pkcs12_create
    pubkey = Key.find(params[:id])
    privkey = Net::SSH::KeyFactory.load_data_private_key(params[:ssh_priv_key].read)
    send_data OpenSSL::PKCS12.create("", "", privkey, pubkey.x509).to_der,
              :filename => "4am-#{@key.user.login}.p12",
              :type => "application/x-pkcs12"
    #FIXME we should explicitly remove the temporary file
    #FIXME we should handle the errors
  end

end
