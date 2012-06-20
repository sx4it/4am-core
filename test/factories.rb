FactoryGirl.define do
  factory :user do
    login "user"
    email { login + "@yopmail.com" }
    password "admin"
    password_confirmation "admin"
    roles { create_list(:role, 1, :name => login) }
    factory :admin do
      login "admin"
    end

  end

  factory :role do
    name "admin"
  end

  factory :host_group do
    name "host_group"
  end

  factory :host do
    name "host"
    ip "localhost"
    port 42
  end

  factory :host_acl do
    acl_type "Exec"
    hosts { create :host , :name => acl_type + "_host"}
    users { create :user , :login => acl_type + "_user"}
  end

  factory :user_group do
    name "user_group"
  end

  factory :command do
    name "command"
    command "ls -l"
  end

  factory :key do
    name "key"
    ssh_key "ssh-rsa key key"
    user { create :user, :login => name + "_user" }
  end
end
