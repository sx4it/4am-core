# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
#ading default user
u = User.new
u.login = 'admin'
u.password = 'admin'
u.roles << Role.create(:name => 'admin')
u.save

#ading default roles
Role.create :name => 'edit'
Role.create :name => 'exec'
Role.create :name => 'view'
