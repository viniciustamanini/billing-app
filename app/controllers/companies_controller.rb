class CompaniesController < ApplicationController
  before_action :authenticate_user!

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      admin_profile_type = ProfileType.find_by(name: "administrator")

      current_user.profiles.create!(
        company: @company,
        profile_type: admin_profile_type,
        default_profile: true,
        active: true
      )

      redirect_to root_path, success: "Company was successfully created."
    else
      render :new
    end
  end

  def show
  end

  private

  def company_params
    params.require(:company).permit(:name, :address, :city, :state, :zip_code, :country, :email)
  end
end
