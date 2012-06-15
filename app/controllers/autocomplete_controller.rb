class AutocompleteController < ApplicationController

  def autocomplete_user_login
    term = params[:term]
    data = User.where('login like ?', "#{term}%").limit(10).append(UserGroup.where('name like ?', "#{term}%").limit(10)).flatten[0..10]
    render :json => json_for_autocomplete(data, :name, [:type])
  end

  def autocomplete_host_name
    term = params[:term]
    data = Host.where('name like ?', "#{term}%").limit(10).append(HostGroup.where('name like ?', "#{term}%").limit(10)).flatten[0..10]
    render :json => json_for_autocomplete(data, :name, [:type])
  end
end
