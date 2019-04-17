Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope 'api/admin' do
    resources :incidents, only: [:index, :create, :update]
    resources :roles, only: [:index, :create]
    resources :users, only: [:index, :create, :show, :update, :destroy] do
      resources :jwt_api_entreprise, only: [:create] do
        collection do
          post :admin_create
          post :disable, to: 'jwt_api_entreprise#disable'
        end
      end

      member do
        post 'add_roles'
      end

      # User account related routes
      collection do
        post :confirm
        post :login, to: 'doorkeeper/tokens#create'
      end
    end
  end
end
