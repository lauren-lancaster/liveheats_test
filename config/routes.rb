Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root 'pages#home'

  resources :students, only: [:new, :create]
  resources :races, only: [:index, :new, :create, :show] do
    member do
      post :add_student_to_lane
      patch :confirm
      get 'record_results', to: 'races#edit_results'
      patch 'record_results', to: 'races#update_results'
    end
  end
end
