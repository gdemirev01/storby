Rails.application.routes.draw do
  resources :requests
  # devise_for :userrails
  get "/", to: "home#index"
  resources :home, :reviews
  devise_for :users
  devise_for :views
  resources :games
  patch "/games/:id/buy", to: "games#add_to_user"
  get "/users/library", to: "users/custom#library"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
