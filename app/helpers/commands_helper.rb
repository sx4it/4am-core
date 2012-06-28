module CommandsHelper
  def popover(tag, cl, attribute, title, text, href="#")
    content_tag(tag, attribute, :class => ['status'].append(cl).join(" "), :data => {:content => "<code>" + text + "</code>", 'original-title' => title}, :href => href, :rel => 'popover')
  end
end
