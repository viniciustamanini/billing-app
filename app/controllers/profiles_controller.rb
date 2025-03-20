class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def choose
    @profiles = current_user.profiles.includes(:company, :profile_type)
    render :choose
  end

  def select
    profile = current_user.profile.find(params[:id])
    session[:active_profile_id] = profile.id
    case profile.profile_type.name
    when "customer"
      redirect_to customer_dashboard_path
    when "employee"
      redirect_to root_path
    when "administrator"
      redirect_to root_path
    else
      redirect_to choose_profile_path
    end
  end
end
