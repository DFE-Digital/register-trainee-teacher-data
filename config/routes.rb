# frozen_string_literal: true

Rails.application.routes.draw do
  extend SidekiqRoutes
  extend SystemAdminRoutes
  extend ApiRoutes

  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat

  get "/accessibility", to: "pages#accessibility", as: :accessibility
  get "/cookies", to: "pages#cookie_policy", as: :cookie_policy
  get "/privacy-policy", to: "pages#privacy_policy", as: :privacy_policy
  get "/guidance", to: "pages#guidance"

  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  get "/trainees/not-supported-route", to: "trainees/not_supported_routes#index"

  get "/sign-in" => "sign_in#index"
  get "/sign-out" => "sign_out#index"

  get "/sign-in/user-not-found", to: "sign_in#new"

  get "request-an-account", to: "request_an_account#index"

  if FeatureService.enabled?("use_dfe_sign_in")
    get "/auth/dfe/callback" => "sessions#callback"
    get "/auth/dfe/sign-out" => "sessions#signout"
  else
    get "/personas", to: "personas#index"
    get "/auth/developer/sign-out", to: "sessions#signout"
    post "/auth/developer/callback", to: "sessions#callback"
  end

  concern :confirmable do
    resource :confirm_details, as: :confirm, only: %i[show update], path: "/confirm", controller: "/trainees/confirm_details"
  end

  resources :trainees, except: :edit do
    scope module: :trainees do
      resource :training_details, concerns: :confirmable, only: %i[edit update], path: "/training-details"
      resource :publish_course_details, only: %i[edit update], path: "/publish-course-details"
      resource :confirm_publish_course, only: %i[edit update], path: "confirm-publish-course", controller: "/trainees/confirm_publish_course"

      resource :course_details, concerns: :confirmable, only: %i[edit update], path: "/course-details"
      resource :schools, concerns: :confirmable, only: %i[edit update], path: "/schools"
      resource :contact_details, concerns: :confirmable, only: %i[edit update], path: "/contact-details"
      resource :trainee_id, concerns: :confirmable, only: %i[edit update], path: "/trainee-id"
      resource :start_date, concerns: :confirmable, only: %i[edit update], path: "/trainee-start-date"
      resource :training_route, only: %i[edit update], path: "/training-routes"

      get "/confirm-delete", to: "confirm_delete#show"

      namespace :degrees do
        resource :confirm_details, as: :confirm, only: %i[show update], path: "/confirm", controller: "confirm_details"
        get "/new/type", to: "type#new"
        post "/new/type", to: "type#create"
      end

      resources :degrees, only: %i[new edit create update destroy]

      namespace :funding do
        concerns :confirmable
        resource :training_initiative, only: %i[edit update], path: "/training-initiative"
        resource :bursary, only: %i[edit update], path: "/bursary"
      end

      resource :language_specialisms, only: %i[edit update], path: "/language-specialisms"

      resource :personal_details, concerns: :confirmable, only: %i[show edit update], path: "/personal-details"

      namespace :diversity do
        concerns :confirmable
        resource :disclosure, only: %i[edit update], path: "/information-disclosed"
        resource :ethnic_group, only: %i[edit update], path: "/ethnic-group"
        resource :ethnic_background, only: %i[edit update], path: "/ethnic-background"
        resource :disability_disclosure, only: %i[edit update], path: "/disability-disclosure"
        resource :disability_detail, only: %i[edit update], path: "/disabilities"
      end

      resource :outcome_details, only: [], path: "outcome-details" do
        get "confirm"
        get "recommended"
        resource :outcome_date, only: %i[edit update], path: "/outcome-date"
      end

      resource :award_recommendations, only: %i[create]

      resource :confirm_withdrawal, only: %i[show update], path: "/withdraw/confirm"
      resource :withdrawal, only: %i[show update], path: "/withdraw"

      resource :confirm_deferral, only: %i[show update], path: "/defer/confirm"
      resource :deferral, only: %i[show update], path: "/defer"

      resource :confirm_reinstatement, only: %i[show update], path: "/reinstate/confirm"
      resource :reinstatement, only: %i[show update], path: "/reinstate"

      resources :lead_schools, only: %i[index], path: "/lead-schools"
      resource :lead_schools, only: %i[update edit], path: "/lead-schools"
      resources :employing_schools, only: %i[index], path: "/employing-schools"
      resource :employing_schools, only: %i[update edit], path: "/employing-schools"

      namespace :apply_registrations, path: "/apply-registrations" do
        resource :trainee_data, only: %i[update edit], path: "/trainee-data"
        resource :course_details, only: :show, path: "/course-details"
        resource :confirm_courses, only: %i[show update], path: "/confirm-course"
      end

      resource :timeline, only: :show

      resource :subject_specialism, only: %i[edit update], path: "/subject-specialism/:position"
    end

    member do
      get "course-details", to: "trainees/course_details#edit"
      get "publish-course-details", to: "trainees/publish_course_details#edit"
      get "check-details", to: "trainees/check_details#show"
      get "review-draft", to: "trainees/review_draft#show"
    end
  end

  resources :trn_submissions, only: %i[create show], param: :trainee_id, path: "trainee-registrations"

  root to: "pages#start"
end
