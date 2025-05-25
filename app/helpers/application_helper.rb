module ApplicationHelper
  include Pagy::Frontend

  def profile_root_path(profile = nil)
    profile ||= current_user.profiles.find_by(id: session[:active_profile_id])

    return choose_profile_path unless profile

    if customer_profile_type?(profile.profile_type.name)
      customer_dashboard_path()
    else
      company_dashboard_path(profile.company)
    end
  end

  def customer_profile_type?(profile_type)
    profile_type == "customer"
  end

  def admin_profile_type?(profile_type)
    profile_type == "administrator"
  end

  def current_profile_display_name
    return "Dashboard" unless @company_name && @profile_type_display

    if customer_profile_type?(@profile_type)
      "#{@profile_type_display}"
    else
      "#{@profile_type_display} - #{@company_name}"
    end
  end
end
