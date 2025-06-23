class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: %i[ show collaborators ]

  def new
    @company = Company.new
  end

  def modal_new
    @company = Company.new
    render :modal_new, layout: false
  end

  def create
    default_profile = ActiveModel::Type::Boolean.new.cast(params[:default_profile]) || false
    @company = CompanyCreator.new(current_user, company_params, default_profile).call

    if @company.persisted?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append(
              "toasts",
              partial: "shared/toast",
              locals: {
                message: "Company was successfully created!",
                icon: "success",
                show_undo: false
              }
            )
          ]
        end
        format.html { redirect_to root_path, flash: { success: "Company was successfully created!" } }
      end
    else
      flash.now[:error] = "Erro"
      render :modal_new, layout: false, status: :unprocessable_entity
    end
  end

  def show
    load_collaborators(search: params[:search])
  end

  def collaborators
    load_collaborators(search: params[:search])
    #
    # respond_to do |format|
    #   format.html
    #   format.turbo_stream
    # end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash.now[:warning] = e.message
  end

  def load_collaborators(search: nil)
    scope = @company
            .profiles
            .includes(:user, :profile_type)
            .joins(:profile_type)
            .where(profile_types: { name: %w[administrator employee] })

    @collaborators_count = scope.count

    if search.present?
      scope = scope.joins(:user)
                   .where(
                     "users.first_name ILIKE :q OR users.last_name ILIKE :q",
                     q: "%#{search}%"
                   )
    end

    @collaborators = scope
    @administrators = scope.by_type("administrator")
    @employees      = scope.by_type("employee")
  end

  def company_params
    params.require(:company).permit(:name, :address, :city, :state, :zip_code, :country, :email)
  end
end
