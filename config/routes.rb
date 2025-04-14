Rails.application.routes.draw do
  scope ":locale", locale: /en|pt/ do
    devise_for :users, controllers: {
      registrations: "users/registrations"
    }

    get "up" => "rails/health#show", as: :rails_health_check

    resources :companies, only: %i[new create show] do
      collection do
        get "companies/modal_new", to: "companies#modal_new", as: :modal_new
      end
    end
    get "profiles/choose", to: "profiles#choose", as: :choose_profile
    get "customer_dashboard", to: "customer_dashboard#index", as: :customer_dashboard

    root "dashboard#index"
  end

  # Redirects to the default locale if none is specified
  get "/", to: redirect("/#{I18n.default_locale}")
end
