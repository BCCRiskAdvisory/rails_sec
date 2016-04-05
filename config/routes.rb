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


  # get 'rails_vulnerabilities/authenticated_page' => 'rails_vulnerabilities#authenticated_page'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
