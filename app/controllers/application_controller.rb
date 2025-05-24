class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  layout :layout_by_resource

  before_action :set_locale
  before_action :set_profile_data, if: :user_signed_in?

  add_flash_types :success, :error, :info, :warning

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def after_sign_in_path_for(resource)
    choose_profile_path
  end

  def current_profile
    return unless current_user && session[:active_profile_id]
    @current_profile ||= current_user.profiles.find_by(id: session[:active_profile_id])
  end
  helper_method :current_profile

  private

  def set_profile_data
    return unless current_profile

    @current_profile = current_profile
    @company = @current_profile.company
    @company_name = @company&.name
    @profile_type = @current_profile.profile_type.name
    @profile_type_display = case @profile_type
                           when 'administrator'
                             'Admin'
                           when 'employee'
                             'Funcionário'
                           when 'customer'
                             'Cliente'
                           else
                             @profile_type.capitalize
                           end
  end

  def layout_by_resource
    if devise_controller?
      "auth"
    else
      "application"
    end
  end
end
