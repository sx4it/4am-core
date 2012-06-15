authorization do

  role :guest do
      has_permission_on [:keys], :to => [:new, :create]
      has_permission_on [:keys], :to => [:index, :show, :new, :create, :edit, :update, :destroy] do
        if_attribute :user => is { user }
      end
      has_permission_on [:users], :to => [:show, :edit, :keys, :update] do
        if_attribute :id => is { user.id }
      end
      has_permission_on [:user_groups], :to => [:show, :index] do
        if_attribute :user => contains { user }
      end
      has_permission_on [:hosts, :host_groups], :to => [:show, :index] do
        if_attribute :host_acl => {:users => is { user }}
        if_attribute :host_acl => {:users => { :user => contains { user } }}
        if_attribute :host_group => {:host_acl => {:users => { :user => contains { user } }}}
        if_attribute :host_group => {:host_acl => {:users => is { user } }}
      end
      has_permission_on [:hosts, :host_groups], :to => [:show, :index] do
        if_attribute :host_acl => {:acl_type => is { "Read" }, :users => is { user }}
        if_attribute :host_acl => {:acl_type => is { "Read" }, :users => { :user => contains { user } }}
        if_attribute :host_group => {:host_acl => {:acl_type => is { "Read" }, :users => {  :user => contains { user } }}}
        if_attribute :host_group => {:host_acl => {:acl_type => is { "Read" }, :users => is { user } }}
      end
      has_permission_on [:hosts, :host_groups], :to => [:show, :index, :edit, :update] do
        if_attribute :host_acl => {:acl_type => is { "Edit" }, :users => is { user }}
        if_attribute :host_acl => {:acl_type => is { "Edit" }, :users => { :user => contains { user } }}
        if_attribute :host_group => {:host_acl => {:acl_type => is { "Edit" }, :users => {  :user => contains { user } }}}
        if_attribute :host_group => {:host_acl => {:acl_type => is { "Edit" }, :users => is { user } }}
      end
      has_permission_on [:hosts, :host_groups], :to => [:show, :index, :edit, :update, :execute] do
        if_attribute :host_acl => {:acl_type => is { "Exec" }, :users => is { user }}
        if_attribute :host_acl => {:acl_type => is { "Exec" }, :users => { :user => contains { user } }}
        if_attribute :host_group => {:host_acl => {:acl_type => is { "Exec" }, :users => {  :user => contains { user } }}}
        if_attribute :host_group => {:host_acl => {:acl_type => is { "Exec" }, :users => is { user } }}
      end
      has_permission_on [:hosts, :host_groups], :to => [:show, :index, :edit, :update, :execute, :sudo] do
        if_attribute :host_acl => {:acl_type => is { "Sudo" }, :users => is { user }}
        if_attribute :host_acl => {:acl_type => is { "Sudo" }, :users => { :user => contains { user } }}
        if_attribute :host_group => {:host_acl => {:acl_type => is { "Sudo" }, :users => {  :user => contains { user } }}}
        if_attribute :host_group => {:host_acl => {:acl_type => is { "Sudo" }, :users => is { user } }}
      end
  end

  role :admin do
      has_omnipotence
  end

  role :view do
      includes :guest
      has_permission_on [:log], :to => [:index]
      has_permission_on [:users], :to => [:index, :show]
      has_permission_on [:host_acls], :to => [:index, :show]
      has_permission_on [:user_groups], :to => [:index, :show]
      has_permission_on [:commands], :to => [:index, :show]
      has_permission_on [:host_groups], :to => [:index, :show]
      has_permission_on [:hosts], :to => [:index, :show]
  end

  role :exec do
      includes :view
      has_permission_on [:commands], :to => [:index, :show]
      has_permission_on [:hosts], :to => [:execute] do
        if_permitted_to :show
      end
      has_permission_on [:host_groups], :to => [:execute] do
        if_permitted_to :show
      end
  end

  role :manage_acl do
      includes :view
      has_permission_on :host_acls, :to => [:crud]
  end
  role :edit do
      includes :view
      has_permission_on [:commands], :to => [:crud]
      has_permission_on [:hosts], :to => [:crud] do
        if_permitted_to :show
      end
      has_permission_on [:host_groups], :to => [:create, :edit, :update, :destroy] do
        if_permitted_to :show
      end
  end

end

privileges do
  privilege :execute do
  end
  privilege :sudo do
  end
  privilege :crud do
    includes :index, :show, :new, :create, :edit, :update, :destroy
  end
  privilege :access
end
