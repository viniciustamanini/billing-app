class CompaniesController < ApplicationController
  before_action :authenticate_user!

  def new
    @company = Company.new
  end

  def create
    default_profile = params[:default_profile]
    @company = CompanyCreator.new(current_user, company_params, default_profile).call
    redirect_to root_path, flash: { success: "Company was successfuly created!" }
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:error] = e.message
    render new
  end

  def show
  end

  private

  def company_params
    params.require(:company).permit(:name, :address, :city, :state, :zip_code, :country, :email)
  end
end
