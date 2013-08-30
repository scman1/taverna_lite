Rails.application.routes.draw do

  resources :workflows


  mount TavernaLite::Engine => "/taverna_lite"
end
