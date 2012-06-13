authorization do

  role :guest do
      has_permission_on [:keys], :to => [:new, :create]
      has_permission_on [:keys], :to => [:show, :new, :create, :edit, :update, :destroy] do
        if_attribute :user => is { user }
      end
      has_permission_on [:users], :to => [:show, :edit, :keys] do
        if_attribute :id => is { user.id }
      end
      has_permission_on [:hosts], :to => [:show] do
        if_attribute :host_acl => {:users => is { user }}
        if_attribute :host_acl => {:users => { :user => contains { user } }}
      end
      has_permission_on [:host_groups], :to => [:show] do
        if_attribute :host_acl => {:users => is { user }}
        if_attribute :host_acl => {:users => { :user => contains { user } }}
      end
  end

  role :admin do
      includes :guest
      has_permission_on [:hosts], :to => [:crud, :execute]
      has_permission_on [:host_groups], :to => [:crud, :execute]
      has_permission_on [:users], :to => [:crud, :add_role, :delete_role]
      has_permission_on [:roles], :to => [:crud]
      has_permission_on [:keys], :to => [:crud]
      has_permission_on [:user_groups], :to => [:crud, :add_user, :del_user]
      has_permission_on [:host_groups], :to => [:crud, :add_host, :del_host]
      has_permission_on [:commands], :to => [:crud]
      has_permission_on :authorization_rules, :to => :read
  end

  role :view do
      includes :guest
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
  privilege :crud do
    includes :index, :show, :new, :create, :edit, :update, :destroy
  end
end
