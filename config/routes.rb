Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      post '/users/signup', to: 'users#signup'
      post '/users/login', to: 'users#login'
      put '/users/forgot_password', to: 'users#forgetPassword'
      put '/users/reset_password/:id', to: 'users#resetPassword'
    end
  end
end
