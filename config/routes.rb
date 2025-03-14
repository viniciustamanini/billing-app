Rails.application.routes.draw do
  get "profiles/choose"
  scope ":locale", locale: /en|pt/ do
    devise_for :users, controllers: {
      registrations: "users/registrations"
    }
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check

    # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
    # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
    # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

    get "profiles/choose", to: "profiles#choose", as: :choose_profile

    root "dashboard#index"
  end

  # Redirects to the default locale if none is specified
  get "/", to: redirect("/#{I18n.default_locale}")
end
