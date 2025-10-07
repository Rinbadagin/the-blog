Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "/articles/get_html_from_docx" => "articles#get_html_from_docx"
  resources :articles
  resources :uploads, param: :title
  resources :guestbook
  resources :webring_node
  get "/notes/submitted" => "notes#submitted"
  resources :notes
  root "articles#index"
  # Defines the root path route ("/")
  # root "posts#index"
  get "/login" => "sessions#new"
  post "/login" => "sessions#create"
  get "/logout" => "sessions#destroy"
  get "music_player", to: "music_player#index"
  get "/ring/transfemring.js" => "webring_node#transfemring"
end
