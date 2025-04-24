class CompanyDashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_profile
  before_action :set_company

  def index
    # Get data specific to the company dashboard
    @company_name = @company.name
    @profile_type = @current_profile.profile_type.name

    # Render the appropriate dashboard view
    render "company_dashboard/#{@profile_type}_dashboard"
  end

  private

  def set_current_profile
    @current_profile = current_user.profiles.find_by(id: session[:active_profile_id])
    
    unless @current_profile
      redirect_to choose_profile_path
      return
    end
    
    # Verify the profile belongs to the requested company
    unless @current_profile.company_id.to_s == params[:company_id]
      redirect_to choose_profile_path
      return
    end
  end

  def set_company
    @company = @current_profile.company
  end
end 