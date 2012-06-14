module HostAclsHelper
  def host_render host
    link_to host.name, host
  end
  def icon name
    "<i class='#{name}'>"
  end
  def get_type type
    if type == "User"
      'user'
    elsif type == "UserGroup"
      'group'
    elsif type == "HostGroup"
      'group'
    else
      'host'
    end
  end
  def render_icon type
    haml_tag :i, :class => "custom-icon icon_#{get_type type}"
  end
end
