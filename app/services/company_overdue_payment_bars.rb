class CompanyOverduePaymentBars
  def initialize(company)
    @company = company
  end

  def call
    @company.overdue_ranges
            .active
            .order(:days_from)
            .map { |range| stats_for(range) }
  end

  private

  def overdue_invoices
    @overdue_invoices ||= @company.invoices
        .joins(:invoice_status)
        .where(invoice_statuses: { name: "overdue" })
  end

  def stats_for(range)
    invoices_in_range = overdue_invoices
        .where("due_date <= ?", Date.current - range.days_from)
        .where("due_date > ?", Date.current - range.days_to)

    total_in_range = invoices_in_range.count
    paid_in_range = invoices_in_range.paid.count
    
    percentage = total_in_range.positive? ? ((paid_in_range.to_f / total_in_range) * 100).round : 0
    
    {
      label: "#{range.days_from} a #{range.days_to}",
      percentage: percentage,
      total: total_in_range,
      paid: paid_in_range
    }
  end
end
