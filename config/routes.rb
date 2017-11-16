Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope 'api/admin' do
    resources :roles, only: [:index, :create]
    resources :users, only: [:index, :create, :show, :update, :destroy] do
      resources :tokens, only: [:create]
    end
  end
end
