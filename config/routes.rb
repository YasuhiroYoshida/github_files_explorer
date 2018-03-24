Rails.application.routes.draw do
  resources :files_explorer, only: [:index]
  root 'files_explorer#index'
end
