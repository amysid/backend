Rails.application.routes.draw do
  namespace :api do
    scope "(:locale)", locale: /en|ar/ do 
      post "login", to: "sessions#create"
      resources :sessions
      resources :users
      resources :categories
      resources :booths
    end
  end
end
