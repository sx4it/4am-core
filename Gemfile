source 'http://rubygems.org'

gem 'rails', '~> 3.2.0'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

group :development do
    gem 'sqlite3'
end
gem 'redis'
gem 'log4r'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'

  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'

  gem 'bootstrap-sass', '~> 2.0.2'

  gem "jquery-rails", "~> 1.0.12"
  gem "jquery-ui-rails"
  #gem 'compass'
end


gem 'therubyracer'
gem 'haml'
gem 'haml-rails'


#gem 'mongrel'

gem "will_paginate"

gem 'authlogic'
gem "authlogic_haapi"

gem 'rails3-jquery-autocomplete', :git => 'https://github.com/coat/rails3-jquery-autocomplete.git'

# getting it from git because the other one does not reload in dev mod
gem "declarative_authorization", :git => 'https://github.com/stffn/declarative_authorization.git'
gem "ruby_parser"

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
#gem 'rvm-capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end

group :production do
    gem 'mysql2'
end


