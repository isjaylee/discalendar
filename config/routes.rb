Rails.application.routes.draw do
  devise_for :users, controllers: { 
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  root "calendars#index"
  get "/auth/:provider/callback", to: "sessions#create"
end
