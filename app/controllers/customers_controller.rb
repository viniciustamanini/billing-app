class CustomersController < ProfilesController
  private

  def set_profile_type
    @profile_type = ProfileType.customer
  end
end
