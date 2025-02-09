class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.limit(5)
  end
end
