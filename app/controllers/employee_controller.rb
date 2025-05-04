class EmployeeController < ProfilesController
  private
  def set_profile_type
    @profile_type = ProfileType.employee
  end
end
