class UserSession < Authlogic::Session::Base
  params_key :api_key
  single_access_allowed_request_types :any
end
