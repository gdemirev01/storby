Rails.application.routes.draw do
  resources :credit_cards
  resources :requests
  # devise_for :userrails
  get "/", to: "home#index"
  resources :home, :reviews
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' } do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  
  devise_for :views
  resources :games
  patch "/games/:id/buy", to: "games#add_to_user"
  get "/users/library", to: "users/custom#library"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
