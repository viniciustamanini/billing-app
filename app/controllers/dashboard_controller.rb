class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.limit(5)
    @profiles = current_user.profiles.includes(:company, :profile_type)
  end
end
