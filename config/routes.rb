TavernaLite::Engine.routes.draw do
  resources :workflow_profiles
  root to: "workflow_profile#edit"
end
