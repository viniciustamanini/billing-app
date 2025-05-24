class CompanyRenegotiations
  def initialize(company)
    @company = company
  end

  def call
    Renegotiation
      .where(company: @company)
    ## TODO filter by a date
  end
end
