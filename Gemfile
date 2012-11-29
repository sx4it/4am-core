source 'http://rubygems.org'

gem 'rails', '~> 3.2.0'

group :development do
    gem 'sqlite3'
    gem 'awesome_print'
    # quiet asset for dev mode :)
    gem 'quiet_assets'
    # getting it from git to allow dynamic reloading
    #gem "declarative_authorization", :git => 'https://github.com/stffn/declarative_authorization.git'
    gem 'capistrano'
    gem 'rvm-capistrano'
end

gem 'redis'
gem 'log4r'


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
  gem 'therubyracer'
  gem 'haml'
  gem 'haml-rails'
end

gem "will_paginate"

gem 'authlogic'
gem "authlogic_haapi"

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# We can only use passenger as web server because unicorn and webrick do not
# support to receive the raw ssl certificate via an environment variable
gem 'passenger'
gem 'net-ssh'

gem "declarative_authorization"
gem "simple_form"
gem "cocoon"
gem 'public_activity'
gem 'client_side_validations'
gem 'client_side_validations-simple_form'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'factory_girl_rails'
end

group :test, :development do
    gem "rspec-rails"
    gem "capybara"
    gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
    gem 'guard-rspec'
    gem 'sqlite3'
end

group :production do
    gem 'mysql2'
end
