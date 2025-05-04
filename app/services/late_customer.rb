class LateCustomer
  def initialize(company)
    @company = company
  end

  def call
    company_customers = Profile
      .where(company: @company)
      .by_type("customer")
      .order(:id)
      .limit(8)

    company_customers
  end
end
