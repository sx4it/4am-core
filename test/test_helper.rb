ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'declarative_authorization/maintenance'
require 'authlogic/test_case'

class ActiveSupport::TestCase
  include Authorization::TestHelper
  fixtures :all
  include FactoryGirl::Syntax::Methods
  include Authlogic::TestCase
  attr_reader :admin
  setup do
    activate_authlogic
    @admin = create(:admin)
    UserSession.create(@admin)
  end
end

class ActionController::TestCase
  include Authorization::TestHelper
  include FactoryGirl::Syntax::Methods
  include Authlogic::TestCase
  attr_reader :admin
  setup do
    activate_authlogic
    @admin = create(:admin)
    UserSession.create(@admin)
  end
end
