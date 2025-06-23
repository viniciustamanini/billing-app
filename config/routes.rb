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
      resources :renegotiations, only: [ :index, :show ] do
        member do
          patch :cancel
          patch :accept
          patch :reject
        end
      end

      # Customer renegotiations - separate from company renegotiations
      resources :customer_renegotiations, controller: "customer_renegotiations", only: [:index, :show] do
        member do
          patch :accept
          patch :reject
        end
        collection do
          get "invoices/:invoice_id/new_proposal", to: "customer_renegotiations#new_proposal", as: :new_invoice_proposal
          post "invoices/:invoice_id/create_proposal", to: "customer_renegotiations#create_proposal", as: :create_invoice_proposal
        end
      end

      # TODO maybe the customer_dashboard and customer controller should be just one
      resources :profiles, only: [] do
        get "customer_dashboard", to: "customer_dashboard#index_for_company", as: :customer_dashboard
        get "invoices/new_item", to: "invoices#new_item", as: :new_invoice_item
        resources :invoices, only: %i[index new create show edit update] do
          member do
            patch :mark_as_paid
          end
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
    get "company_dashboard/:company_id/chart_data", to: "company_dashboard#chart_data", as: :company_dashboard_chart_data

    root "profiles#choose"
  end

  # Redirects to the default locale if none is specified
  get "/", to: redirect("/#{I18n.default_locale}")
end
