class CompaniesController < ApplicationController
  before_action :authenticate_user!

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
      redirect_to root_path, flash: { success: "Company was successfuly created!" }
    else
      flash.now[:error] = "Erro"
      render :modal_new, layout: false, status: :unprocessable_entity
    end
  end

  def show
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash.now[:warning] = e.message
  end

  private

  def company_params
    params.require(:company).permit(:name, :address, :city, :state, :zip_code, :country, :email)
  end
end
