class ProfilesController < ApplicationController
  before_action :authenticate_user!
  layout "choose_profile", only:  [ :choose ]

  def choose
    @profiles = current_user.profiles.includes(:company, :profile_type).order(:id)
    @company = Company.new
    render :choose
  end

  def select
    profile = current_user.profiles.find(params[:id])
    session[:active_profile_id] = profile.id
    case profile.profile_type.name
    when "customer"
      redirect_to customer_dashboard_path
    when "employee"
      redirect_to company_dashboard_path(company_id: profile.company_id)
    when "administrator"
      redirect_to company_dashboard_path(company_id: profile.company_id)
    else
      redirect_to choose_profile_path
    end
  end

  def update_default
    @profile = current_user.profiles.find(params[:id])

    # Find all other profiles that need to be updated
    other_profiles = current_user.profiles.where.not(id: @profile.id)

    Profile.transaction do
      current_user.profiles.update_all(default_profile: false)
      @profile.update!(default_profile: true)
    end

    respond_to do |format|
      format.turbo_stream do
        turbo_streams = [
          turbo_stream.append(
            "toasts",
            partial: "shared/toast",
            locals: {
              message: "Perfil alterado",
              icon: "success",
              show_undo: true
            }
          )
        ]

        # Add streams to update other checkboxes' checked state
        other_profiles.each do |profile|
          turbo_streams << turbo_stream.update(
            "profile_checkbox_#{profile.id}",
            partial: "profiles/checkbox_input",
            locals: { profile: profile, is_default: false }
          )
        end

        # Add stream to ensure the current checkbox remains checked
        turbo_streams << turbo_stream.update(
          "profile_checkbox_#{@profile.id}",
          partial: "profiles/checkbox_input",
          locals: { profile: @profile, is_default: true }
        )

        render turbo_stream: turbo_streams
      end
      format.json { render json: { success: true, message: "Profile updated successfully" } }
      format.html {
        flash[:success] = "Sucesso"
        redirect_to choose_profiles_path
      }
    end
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append(
            "toasts",
            partial: "shared/toast",
            locals: {
              message: "Falha ao executar",
              icon: "error",
              show_undo: false
            }
          )
        ]
      end
      format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
      format.html do
        flash[:error] = "Falha ao executar"
        redirect_to choose_profiles_path
      end
    end
  end
end
