# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
#ading default user
u = User.new
u.login = 'admin'
u.password = 'admin'
u.password_confirmation = 'admin'
admin = Role.create(:name => 'admin')
u.roles << admin
u.save

Command.create :name => 'ls', :command => 'ls -l'
Command.create :name => 'uname', :command => 'uname -a'
Command.create :name => 'ping google', :command => 'ping google.com'
Command.create :name => 'add_user', :command => <<EOF
  useradd -m <%= user[:login] %>;
  mkdir ~<%=user[:login]%>/.ssh/ ;
  <% user[:keys].each do |k| %>
  echo "<%=k%>">> ~<%=user[:login]%>/.ssh/authorized_keys ;
  <% end %>
  chown -R <%=user[:login]%> ~<%=user[:login]%>/ ;
EOF
Command.create :name => 'del_user', :command => 'userdel -r -f <%= user[:login] %>;'

#TODO command add user

#ading default roles
Role.create :name => 'edit'
Role.create :name => 'exec'
Role.create :name => 'view'
Role.create :name => 'manage_acl'
