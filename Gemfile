source 'http://rubygems.org'

gem 'rails', '~> 3.2.0'

gem 'minitest'
# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

group :development do
    gem 'sqlite3'
    # quiet asset for dev mode :)
    gem 'quiet_assets'
    # getting it from git to allow dynamic reloading
    #gem "declarative_authorization", :git => 'https://github.com/stffn/declarative_authorization.git'
    gem 'capistrano'
    gem 'rvm-capistrano'
end

gem 'sqlite3'
gem 'redis'
gem 'log4r'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'capistrano'
  gem 'sass-rails', '~> 3.2.3'
  gem 'compass-rails'

  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'

  gem 'bootstrap-sass', '~> 2.0.2'

  gem "jquery-rails", "~> 1.0.12"
  gem "jquery-ui-rails"

  gem 'font-awesome-sass-rails'
end


gem 'therubyracer'
gem 'haml'
gem 'haml-rails'

gem 'ruby-prof'


#gem 'mongrel'
gem 'factory_girl_rails'

gem "will_paginate"

gem 'authlogic'
gem "authlogic_haapi"

gem "ruby_parser"

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
#gem 'unicorn'

# Deploy with Capistrano
#gem 'rvm-capistrano'
# We can only use passenger as web server because unicorn and webrick do not
# support to receive the raw ssl certificate via an environment variable
gem 'passenger'
gem 'net-ssh'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
#
#
gem "declarative_authorization"
gem "simple_form"
gem "cocoon"
gem 'public_activity'
gem 'client_side_validations'
gem 'client_side_validations-simple_form'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end

group :production do
    gem 'mysql2'
end



