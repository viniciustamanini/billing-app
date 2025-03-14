class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def choose
    @profiles = current_user.profiles.includes(:company, :profile_type)

    render :choose
  end
end
