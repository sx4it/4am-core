authorization do
  role :admin do
      has_permission_on [:hosts], :to => [:index, :show, :new, :create, :edit, :update, :destroy]
      has_permission_on [:users], :to => [:index, :show, :new, :create, :edit, :update, :destroy]
      has_permission_on [:roles], :to => [:index, :show, :new, :create, :edit, :update, :destroy]
      has_permission_on :authorization_rules, :to => :read
  end
  role :user do
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
end
