Rails.application.routes.draw do
  scope ":locale", locale: /en|pt/ do
    devise_for :users, controllers: {
      registrations: "users/registrations"
    }

    get "up" => "rails/health#show", as: :rails_health_check

    resources :companies, only: %i[new create show] do
      get :collaborators, on: :member
      collection do
        get :modal_new, to: "companies#modal_new"
      end
      resources :renegotiations, only: [:index, :show] do
        member do
          patch :cancel
          patch :accept
          patch :reject
        end
      end

      # TODO maybe the customer_dashboard and customer controller should be just one
      resources :profiles, only: [] do
        get "customer_dashboard", to: "customer_dashboard#index_for_company", as: :customer_dashboard
        get "invoices/new_item", to: "invoices#new_item", as: :new_invoice_item
        resources :invoices, only: %i[index new create show edit update] do
          resource :renegotiation, controller: "renegotiations", only: %i[create] do
            get :options
            get :recalculate
          end
        end
      end
      resources :customers, controller: "customers", only: %i[new create] do
        collection do
          get :modal_new, to: "customers#modal_new"
          get :index, to: "customers#index"
        end
      end

      resources :segments, except: %i[ destroy ] do
        member do
          patch :deactivate
          patch :activate
        end
      end

      resources :overdue_ranges, except: %i[ destroy ] do
        member do
          patch :deactivate
          patch :activate
        end
      end

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
