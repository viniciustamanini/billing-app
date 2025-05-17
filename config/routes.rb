Rails.application.routes.draw do
  scope ":locale", locale: /en|pt/ do
    devise_for :users, controllers: {
      registrations: "users/registrations"
    }

    get "up" => "rails/health#show", as: :rails_health_check

    resources :companies, only: %i[new create show] do
      collection do
        get :modal_new, to: "companies#modal_new"
      end

      resources :customers, controller: "customers", only: %i[new create] do
        collection do
          get :modal_new, to: "customers#modal_new"
        end
      end

      resources :segments, only: %i[index new create edit update]
      resources :employees, controller: "employees", only: %i[new create]
    end

    resources :profiles, only: [] do
      member do
        patch :update_default
      end
    end

    get "profiles/choose", to: "profiles#choose", as: :choose_profile
    get "profiles/:id/select", to: "profiles#select", as: :select_profile
    get "customer_dashboard", to: "customer_dashboard#index", as: :customer_dashboard
    get "company_dashboard/:company_id", to: "company_dashboard#index", as: :company_dashboard

    root "profiles#choose"
  end

  # Redirects to the default locale if none is specified
  get "/", to: redirect("/#{I18n.default_locale}")
end
