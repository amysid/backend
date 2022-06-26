Rails.application.routes.draw do
  
  namespace :web_api do
    scope "(:locale)", locale: /en|ar/ do
      resources :booths do 
        get :booth_cover_urls, on: :member
      end
    end
  end

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
      resources :homes
      resources :books do 
        get :change_status, on: :member
      end
    end
  end
end
