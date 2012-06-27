class LogController < ApplicationController
  filter_resource_access
  def index
    @old_command = Cmd.all
  end
end
