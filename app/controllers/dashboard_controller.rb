
class DashboardController < ApplicationController
  def index
    @hosts = Host.with_permissions_to(:show)
    @hosts << HostGroup.with_permissions_to(:show)
    @hosts = @hosts.flatten
  end
end
