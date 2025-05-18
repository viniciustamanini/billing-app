class CustomersController < ProfilesController
  def index
    @customers = @company.profiles
      .by_type("customer")

    if params[:search].present?
      @customers = @customers.where("profiles.first_name ILIKE ?", "%#{params[:search]}%")
    end

    @customers
  end

  private

  def set_profile_type
    @profile_type = ProfileType.customer
  end
end
