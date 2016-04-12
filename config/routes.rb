Rails.application.routes.draw do

  resources :users

  root :to => 'root#index'

  examples = {
    :os_injection => [:injectable, :search_dir, :blacklist, :blind, :search_dir_relative],
    :xss => [:raw, :encoded, :attrs, :js_encoded],
    :sql_injection => []
  }

  examples.each do |example, routes|
    get example.to_s, :to => "#{example}#index"

    routes.each do |route|
      post "#{example}/#{route}"
    end

  end

  get 'rails_vulnerabilities' => 'rails_vulnerabilities#index'
  match 'rails_vulnerabilities/render' => 'rails_vulnerabilities#render_view', :via => [:post, :get]
  post 'rails_vulnerabilities/xss_in_json' => 'rails_vulnerabilities#xss_in_json'

  get 'intro/:tpl' => 'intro#index'

end
