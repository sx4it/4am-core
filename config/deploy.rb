set :rvm_type, :system
set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")

require "rvm/capistrano"

set :application, "4am-core"
set :repository,  "git://github.com/sx4it/4am-core.git" # read only git

#set :user, "4am" # deploying as root
set :deploy_to, "/opt/4am/www"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

app = ENV['CORE_4AM']

if app.nil?
  puts "no environement variable called CORE_4AM try 'export CORE_4AM=<ip>'"
end


role :web, app
role :app, app
role :db, app, :primary => true

#set :shared_files, ["config/4am.yml", "config/4am-ca.crt", "config/4am-ca.key", "config/database.yml"]

set :use_sudo, false
set :keep_releases, 3


# rvm install
# we assume it is already installed
#
#before 'deploy:setup', 'rvm:install_rvm'
#before 'deploy', 'rvm:install_rvm'

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end

after "deploy", "rvm:trust_rvmrc"


# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:

namespace :config_4am do
  task :setup, :except => { :no_release => true } do
    default_db = <<-EOF
      base: &base
        adapter: sqlite3
        timeout: 5000
      development:
        database: #{shared_path}/db/dev.sqlite3
        <<: *base
      test:
        database: #{shared_path}/db/test.sqlite3
        <<: *base
      production:
        adapter: mysql2
        encoding: utf8
        database: 4amcore
        pool: 10
        username: root
        password:
        host: 127.0.0.1
    EOF

    default_4am = <<-EOF
      defaults: &defaults
        redis:
          host: 127.0.0.1
          port: 6379
        ssl:
          ca_crt: #{shared_path}/config/4am-ca.crt
          ca_key: #{shared_path}/config/4am-ca.key

      development:
        <<: *defaults

      test:
        <<: *defaults

      production:
        <<: *defaults
    EOF

    config_db = ERB.new(default_db)
    config_4am = ERB.new(default_4am)

    run "mkdir -p #{shared_path}/db"
    run "mkdir -p #{shared_path}/config"
    put config_db.result(binding), "#{shared_path}/config/database.yml"
    put config_4am.result(binding), "#{shared_path}/config/4am.yml"

    run "ln -nfs #{deploy_to}/../nginx/conf/ssl/server.crt #{shared_path}/config/4am-ca.crt"
    run "ln -nfs #{deploy_to}/../nginx/conf/ssl/server.key #{shared_path}/config/4am-ca.key"
  end

  task :symlink, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/4am-ca.crt #{release_path}/config/4am.ca.crt"
    run "ln -nfs #{shared_path}/config/4am-ca.key #{release_path}/config/4am.ca.key"
    run "ln -nfs #{shared_path}/config/4am.yml #{release_path}/config/4am.yml"
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after "deploy:setup", "config_4am:setup"   unless fetch(:skip_db_setup, false)
after "deploy:finalize_update", "config_4am:symlink"



namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :db do
  desc "migrate and reload the database with seed data"
  task :reset do
    run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:reset"
  end
end
