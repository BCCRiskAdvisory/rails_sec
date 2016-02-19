module ApplicationHelper
  def csrf_token_tag
    "<input type=\"hidden\" value=\"#{form_authenticity_token}\" name=\"authenticity_token\"></input>".html_safe
  end
end
