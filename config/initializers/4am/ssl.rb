# Should be nicer, module/class/whatever

ssl = Rails.application.config.am['ssl']

if ssl
  ca_crt = ssl['ca_crt']
  if ca_crt
    path = Rails.root.join(ca_crt)
    $am_cacrt = OpenSSL::X509::Certificate.new File.read(path) # DER- or PEM-encoded
  else
    puts "cannot load certificate, please add ca_crt path to 4am.yml file"
    $am_cacrt = nil
  end

  ca_key = ssl['ca_key']
  if ca_key
    path = Rails.root.join(ca_key)
    $am_cakey = OpenSSL::PKey::RSA.new File.read(path)
  else
    puts "cannot load certificate, please add ca_key path to 4am.yml file"
    $am_cakey = nil
  end
else
  puts "Cannot read ssl informations in 4am.yml file."
end
