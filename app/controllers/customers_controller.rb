class CustomersController < ProfilesController
  include Pagy::Backend

  def index
    @customers = @company.profiles
      .left_joins(:user)
      .by_type("customer")

    if params[:search].present?
      search_term = "%#{params[:search]}%"

      @customers = @customers
        .where(
          "profiles.first_name ILIKE :q OR profiles.last_name ILIKE :q OR users.first_name ILIKE :q OR users.last_name ILIKE :q",
          q: search_term
        )
      .references(:user)
    end

    @pagy, @customers = pagy(@customers, items: 10)
  end

  private

  def set_profile_type
    @profile_type = ProfileType.customer
  end
end
