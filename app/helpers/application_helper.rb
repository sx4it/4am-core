module ApplicationHelper

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.merge(:sort => column, :direction => direction, :page => nil), {:class => css_class}
  end

  def include_related_js
    # adding _ because index is reserved
    asset = "related/#{params[:controller]}/_#{params[:action]}"
    if !AM::Application.assets.find_asset(asset).nil?
        content_for :javascript_custom do
          javascript_include_tag asset
        end
    end
  end
end
