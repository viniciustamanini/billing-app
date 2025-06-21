class CompanyOverduePaymentBars
  def initialize(company)
    @company = company
  end

  def call
    total = overdue_invoices.count

    @company.overdue_ranges
            .active
            .order(:days_from)
            .index_with { |range| stats_for(range, total) }
  end

  private

  def overdue_invoices
    @overdue_invoices ||= @company.invoices
        .joins(:invoice_status)
        .where(invoice_statuses: { name: "overdue" })
  end

  def stats_for(range, total)
    count = overdue_invoices
        .where("due_date <= ?", Date.current - range.days_from)
        .where("due_date >  ?", Date.current - range.days_to)
        .where("DATE(paid_at) = ?", Date.current)
        .count

    percent = total.positive? ?  ((count.to_f / total) * 100).round : 0
    { percent: percent, total: count }
  end
end
