class Key < ActiveRecord::Base
  KEY_TYPES = %w(ssh-rsa ssh-dss)

  validates :value, :presence => true # FIXME Should probably be checked
  validates :keytype, :presence => true, :inclusion => { :in => KEY_TYPES,
        :message => "%{value} is not a valid key type" }
  belongs_to :user

  attr_accessible :value, :name, :type
  attr_accessor :name_pref, :ssh_key_str

  before_validation do |key|
    if key.ssh_key_str
      ssh_key_arr = key.ssh_key_str.split
      if ssh_key_arr.length != 2 && ssh_key_arr.length != 3
        self.errors['ssh_key'] << "Invalid format, the string is supposed to have two or three fields #{key.ssh_key_str}."
        return false
      end
      unless KEY_TYPES.include? ssh_key_arr[0]
        self.errors['ssh_key'] << "Invalid key type #{key.ssh_key_str}."
        return false
      end
      key[:keytype] = ssh_key_arr[0]
      key[:value] = ssh_key_arr[1]
      unless key.name_pref
        key[:name] = ssh_key_arr[2]
      end
    end
  end

  def ssh_key=(key)
    key = key.read if key.kind_of? ActionDispatch::Http::UploadedFile
    @ssh_key_str = key
  end

  def ssh_key
    "#{self[:keytype]} #{self[:value]} #{self[:name]}"
  end

  def x509
    # Receive a key from the model as paramater
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 2
    cert.subject = OpenSSL::X509::Name.parse "/DC=sx4it/DC=4am/CN=#{self.user.login}"
    cert.issuer = $am_cacrt.subject # $ca_cert is the issuer
    # Convert the key to the openssl format
    cert.public_key = Net::SSH::KeyFactory.load_data_public_key(self.ssh_key)
    cert.not_before = Time.now
    # 100 years validity, I strongly believe that our civilization as it exists
    # now will have disappeared until then 
    cert.not_after = cert.not_before + 100 * 365 * 24 * 60 * 60
    # Do we need this part, the extension ?
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = $am_cacrt
    cert.add_extension(ef.create_extension("keyUsage","digitalSignature", true))
    cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
    cert.sign($am_cakey, OpenSSL::Digest::SHA256.new)
    cert
  end
end
