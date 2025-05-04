class CompanyDashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_profile
  before_action :set_company

  def index
    @company_id = @company.id
    @company_name = @company.name
    @profile_type = @current_profile.profile_type.name
    @late_customers = LateCustomer.new(@company).call

    render "company_dashboard/#{@profile_type}_dashboard"
  end

  private

  def set_current_profile
    @current_profile = current_user.profiles.find_by(id: session[:active_profile_id])

    unless @current_profile
      redirect_to choose_profile_path
      return
    end

    unless @current_profile.company_id.to_s == params[:company_id]
      redirect_to choose_profile_path
      nil
    end
  end

  def set_company
    @company = @current_profile.company
  end
end
