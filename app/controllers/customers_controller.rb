class CustomersController < ProfilesController
  def modal_new
    @customer = @company.profiles.new(profile_type: @profile_type)
    render :modal_new, layout: false
  end

  private

  def set_profile_type
    @profile_type = ProfileType.customer
  end
end
