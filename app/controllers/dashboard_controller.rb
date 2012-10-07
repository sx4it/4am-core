
class DashboardController < ApplicationController
  def index
    @hosts = Host.with_permissions_to(:show)
    @host_group = HostGroup.with_permissions_to(:show)
  end
end
