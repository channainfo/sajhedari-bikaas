Conflict::Application.routes.draw do
  devise_for :users,
    controllers: {
    registrations:  "users/registrations",
    passwords:      "users/passwords",
  }

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  resources :locations do 
    collection do
      get 'import'
      post 'import_process'
      get 'download_location_template'
    end

    member do
      get 'cancel_delete'
      get 'cancel_update'
      get 'approve_delete'
      get 'approve_update'
      get 'view_difference'
      put 'apply_update_form'
    end
  end
  resources :reporters do
    collection do
      get 'getReporterCasesPagination'
      get 'export_csv'
    end
  end

  resources :alerts
  resources :settings

  resources :trends do
    collection do
      get 'fetchCaseForGraph'
      get 'download_csv'
    end
  end

  resources :messages

  resources :conflict_cases do
    collection do
      get 'get_field_options'
      get 'get_indicator_options'
      get 'export_as_kml'
      get 'export_as_shp'
      get 'failed_messages'
    end
    member do
      get 'cancel_delete'
      get 'cancel_update'
      get 'approve_delete'
      get 'approve_update'
      get 'view_difference'
      put 'apply_update_form'
    end
  end
  resources :users do
    collection do
      post 'register'

    end

    member do
      put 'update_password'
      get 'change_password'
    end
  end

  match 'messaging' => 'messaging#index', :via => :post

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
