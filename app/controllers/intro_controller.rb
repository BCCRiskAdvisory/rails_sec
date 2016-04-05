class IntroController < ApplicationController
  def self.templates
    @templates ||= begin
      Dir.glob("#{Rails.root}/app/views/intro/*.html.erb").
        map{ |fn| fn.split("/").last }.
        map{ |fn| fn.split(".").first }
    end
  end

  def index
    if params[:tpl] && IntroController.templates.include?(params[:tpl])
      render params[:tpl]
    end
  end
end
