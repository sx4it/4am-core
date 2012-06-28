if not Rails.application.config.am['redis']['path'].nil?
  Redis.current = Redis.new(:path => Rails.application.config.am['redis']['path'])
else
  Redis.current = Redis.new(:host => Rails.application.config.am['redis']['host'], :port => Rails.application.config.am['redis']['port'])
end
