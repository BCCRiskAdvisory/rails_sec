class RailsVulnerabilitiesController < ApplicationController  

  def index

  end

  def render_view
    render params[:view_name]
  end

  def xss_in_json
    @the_hash = {}
    @the_hash[params[:key]] = params[:value]
  end

end
