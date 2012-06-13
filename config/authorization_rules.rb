authorization do

  role :admin do
      has_permission_on [:hosts], :to => [:index, :show, :new, :create, :edit, :update, :destroy, :execute]
      has_permission_on [:host_groups], :to => [:index, :show, :new, :create, :edit, :update, :destroy, :execute]
      has_permission_on [:users], :to => [:index, :show, :new, :create, :edit, :update, :destroy, :add_role, :delete_role]
      has_permission_on [:roles], :to => [:index, :show, :new, :create, :edit, :update, :destroy]
      has_permission_on :authorization_rules, :to => :read
  end

  role :view do
      has_permission_on [:users], :to => [:show, :edit] do
        if_attribute :id => is { user.id }
      end
      has_permission_on [:hosts], :to => [:show, :index] do
        if_attribute :host_acl => {:users => is { user }}
        if_attribute :host_acl => {:users => { :user => contains { user } }}
      end
      has_permission_on [:host_groups], :to => [:show, :index] do
        if_attribute :host_acl => {:users => is { user }}
        if_attribute :host_acl => {:users => { :user => contains { user } }}
      end
  end

  role :exec do
      includes :view
      has_permission_on [:hosts], :to => [:execute] do
        if_permitted_to :show
      end
      has_permission_on [:host_groups], :to => [:execute] do
        if_permitted_to :show
      end
  end

  role :edit do
      includes :view
      has_permission_on [:hosts], :to => [:show, :index, :create, :edit, :update, :destroy] do
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
end
