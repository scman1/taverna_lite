Rails.application.routes.draw do

  resources :runs


  resources :results


  resources :workflows


  mount TavernaLite::Engine => "/taverna_lite"
end
