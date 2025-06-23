class CompanyRenegotiations
  def initialize(company)
    @company = company
  end

  def call
    @company.renegotiations
      .where(created_at: Date.current.beginning_of_month..Date.current.end_of_month)
  end
end
