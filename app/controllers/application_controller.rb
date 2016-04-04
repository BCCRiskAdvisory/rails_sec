class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_headers

  def set_headers
    response.headers['X-XSS-Protection'] = '0'
  end

end
