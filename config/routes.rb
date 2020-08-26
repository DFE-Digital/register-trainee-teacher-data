Rails.application.routes.draw do
  get "/pages/:page", to: "pages#show"

  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  resources :trainees, only: %i[show new create update] do
    member do
      get "personal-details"
    end
  end
end
