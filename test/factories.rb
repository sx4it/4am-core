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
    association :hosts, factory: :host, strategy: :create, :name => "acl_host"
    association :users, factory: :user, strategy: :create, :login => "acl_user"
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
    association :user, factory: :user, :login => "key_user", strategy: :create
  end
end
