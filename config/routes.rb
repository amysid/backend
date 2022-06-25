Rails.application.routes.draw do
  namespace :api do
    scope "(:locale)", locale: /en|ar/ do 
      post "login", to: "sessions#create"
      resources :sessions
      resources :users do
        get :change_status, on: :member
      end
      resources :categories
      resources :booths
      resources :operations
    end
  end
end
