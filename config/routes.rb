Rails.application.routes.draw do
  devise_for :users, controllers: { 
    omniauth_callbacks: "users/omniauth_callbacks"
  }, skip: [:sessions]

  as :user do
    get "login", to: "devise/sessions#new", as: :new_user_session
    post "login", to: "devise/sessions#create", as: :user_session
    delete "logout", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  root "calendars#index"
  get "about", to: "pages#about", as: :about
  resources :calendars
  get "/auth/:provider/callback", to: "sessions#create"
end
