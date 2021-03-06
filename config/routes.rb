Rails.application.routes.draw do

  root 'order#index'

  get "/get_labs_from_lab/:id" => "lab_processing#get_labs"

  get "/lab_logout" => "lab_processing#index"

  get "/get_specimen_status" => "lab_processing#get_specimen_status"

  get '/change_password' => 'sessions#change_password'

  post '/change_password' => 'sessions#change_password'

  get '/login' => 'sessions#login'
  
  get '/remote_login' => 'remote_sessions#remote_login'
  
  post '/remote_login' => 'remote_sessions#remote_login'

  get '/logout' => 'sessions#logout'
  
  get '/remote_logout' => 'remote_sessions#remote_logout'

  get '/enter_location' => 'sessions#enter_location'

  post '/enter_location' => 'sessions#enter_location'

  get 'sessions/location'

  post 'sessions/login'

  get "/check_test_state" => "lab_processing#check_test_state"

  post "/check_sample_state" => "lab_processing#check_sample_state"

  get 'lab' => "lab_processing#index"

  get "/update_state/:id" => "order#update_state"

  get "/get_labs/:id" => "order#get_labs"

  post "/save_result" => "lab_processing#save_result"

  get "/dispose_sample/:id" => "lab_processing#dispose_sample"

  get "/list_rejection_reasons" => "lab_processing#list_rejection_reasons"

  get "/rejection_reason" => "lab_processing#rejection_reason"

  post "/rejection_reason" => "lab_processing#rejection_reason"

  post "/reject_sample" => "lab_processing#reject_sample"

  get "/process_sample/:id" => "lab_processing#process_sample"

  get "/receive_samples/:id" => "lab_processing#receive_samples"

  get "/sample_status" => "lab_processing#sample_status"

  get "/search_for_samples" => "lab_processing#search_for_samples"

  get "/list_locations" => "lab_processing#list_locations"

  get '/enter_results/:id' => "lab_processing#enter_results"

  get 'lab_processing/verify_results'

  get 'lab_processing/dispose_samples'

  get 'lab_processing/index'

  get 'lab_processing/capture_location'

  post 'lab_processing/set_location'

  get '/check_location/:id' => "lab_processing#check_location"

  get '/process_order' => "order#process_order"

  get '/receptor/:id' => "order#receptor"

  post '/receptor' => "order#receptor"

  get '/patient/:id' => "order#patient"

  get '/catalog' => "order#catalog"

  get '/search_by_npid/:id' => "order#search_by_npid"

  get '/search_by_name' => "order#search_by_name_and_gender"

  get '/search_by_dob' => "order#search_by_name_and_dob"

  get 'order/index'

  get 'order/search'

  get '/place_order/:id' => "order#place_order"

  get 'order/review_results'

  get 'order/print_results'

  get 'order/print_order'

  get '/ward_work_list' => "order#ward_work_list"

  get '/get_state/:id' => "order#get_state"

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
