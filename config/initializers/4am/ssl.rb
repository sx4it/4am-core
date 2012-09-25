# Should be nicer, module/class/whatever

path = Rails.root.join(Rails.application.config.am['ssl']['ca_crt'])
$am_cacrt = OpenSSL::X509::Certificate.new File.read(path) # DER- or PEM-encoded

path = Rails.root.join(Rails.application.config.am['ssl']['ca_key'])
$am_cakey = OpenSSL::PKey::RSA.new File.read(path)
