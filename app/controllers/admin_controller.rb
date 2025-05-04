class AdminController < ProfilesController
  private
  def set_profile_type
    @profile_type = ProfileType.admin
  end
end
