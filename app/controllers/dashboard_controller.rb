
class DashboardController < ApplicationController
  def index
    @hosts = Host.with_permissions_to(:show)
    @host_group = HostGroup.with_permissions_to(:show)
    # TODO improve it
    @activities = PublicActivity::Activity.select do |activity|
      activity.owner == current_user or check_acl_for_activity activity
    end
    @activities = @activities.reverse
  end
  private
  def check_acl_for_activity(elem)
    if self.has_role? :admin
      return true
    end
    unless elem.trackable.nil?
      self.permitted_to? :show, elem.trackable
    end
  end
end
