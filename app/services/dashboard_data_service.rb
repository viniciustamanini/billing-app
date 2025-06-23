class DashboardDataService
  def initialize(company, profile_type = nil)
    @company = company
    @profile_type = profile_type
  end

  def call
    {
      receipts: receipts_data,
      collections: collections_data,
      renegotiations: renegotiations_data,
      overdue_percentage: overdue_percentage,
      payment_bars: payment_bars_data,
      chart_data: chart_data,
      late_customers: late_customers_data
    }
  end

  private

  def receipts_data
    current_month_invoices = @company.invoices
      .where(issued_date: Date.current.beginning_of_month..Date.current.end_of_month)
    
    paid_amount = current_month_invoices.paid.sum(:total_amount)
    overdue_amount = current_month_invoices.overdue.sum(:total_amount)
    
    previous_month_invoices = @company.invoices
      .where(issued_date: 1.month.ago.beginning_of_month..1.month.ago.end_of_month)
    previous_paid_amount = previous_month_invoices.paid.sum(:total_amount)
    
    delta_percentage = previous_paid_amount.zero? ? 0 : 
      ((paid_amount - previous_paid_amount) / previous_paid_amount * 100).round(1)

    {
      total: paid_amount,
      delta: "#{delta_percentage >= 0 ? '+' : ''}#{delta_percentage}%",
      on_time: paid_amount - overdue_amount,
      overdue: overdue_amount
    }
  end

  def collections_data
    # All invoices paid in the current month
    current_month_paid = @company.invoices
      .where(paid_at: Date.current.beginning_of_month..Date.current.end_of_month)
    total_collected = current_month_paid.sum(:total_amount)

    # Notifications sent (approximation based on overdue invoices)
    notifications_sent = @company.invoices.overdue.count

    # Recovered overdue (invoices that were overdue and paid this month)
    recovered_overdue = @company.invoices
      .overdue
      .where(paid_at: Date.current.beginning_of_month..Date.current.end_of_month)
      .sum(:total_amount)

    # Early payments (paid before due date, paid this month)
    early_payments = @company.invoices
      .where(paid_at: Date.current.beginning_of_month..Date.current.end_of_month)
      .where('paid_at < due_date')
      .sum(:total_amount)

    previous_month_collections = @company.invoices
      .where(paid_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month)
      .sum(:total_amount)

    delta_percentage = previous_month_collections.zero? ? 0 :
      ((total_collected - previous_month_collections) / previous_month_collections * 100).round(2)

    {
      total: total_collected,
      delta: "#{delta_percentage >= 0 ? '+' : ''}#{delta_percentage}%",
      notifications_sent: notifications_sent,
      recovered_overdue: recovered_overdue,
      early_payments: early_payments
    }
  end

  def renegotiations_data
    current_month_renegotiations = @company.renegotiations
      .where(created_at: Date.current.beginning_of_month..Date.current.end_of_month)
    
    total_renegotiations = current_month_renegotiations.count
    approved_renegotiations = current_month_renegotiations.approved.count
    
    percentage = total_renegotiations.zero? ? 0 : 
      (approved_renegotiations.to_f / total_renegotiations * 100).round(2)

    {
      total: total_renegotiations,
      approved: approved_renegotiations,
      percentage: percentage
    }
  end

  def overdue_percentage
    total_invoices = @company.invoices.count
    overdue_invoices = @company.invoices.overdue.count
    
    total_invoices.zero? ? 0 : (overdue_invoices.to_f / total_invoices * 100).round(2)
  end

  def payment_bars_data
    @company.overdue_ranges
      .active
      .order(:days_from)
      .map do |range|
        invoices_in_range = @company.invoices.overdue
          .where("due_date <= ?", Date.current - range.days_from)
          .where("due_date > ?", Date.current - range.days_to)
        
        total_in_range = invoices_in_range.count
        paid_in_range = invoices_in_range.paid.count
        
        percentage = total_in_range.zero? ? 0 : (paid_in_range.to_f / total_in_range * 100).round
        
        {
          label: "#{range.days_from} a #{range.days_to}",
          percentage: percentage,
          total: total_in_range,
          paid: paid_in_range
        }
      end
  end

  def chart_data
    dates = 7.days.ago.to_date.upto(Date.current).to_a
    
    dates.index_with do |date|
      invoices_for_date = @company.invoices.where(due_date: date)
      received = @company.invoices.where(paid_at: date.all_day).sum(:total_amount)
      expected = invoices_for_date.sum(:total_amount)
      {
        expected: expected,
        received: received
      }
    end
  end

  def late_customers_data
    # First get the customer IDs with overdue invoices, ordered by most overdue
    customer_ids_with_overdue = @company.profiles
      .by_type('customer')
      .joins(:invoices)
      .where(invoices: { invoice_status: InvoiceStatus.overdue })
      .group('profiles.id')
      .order('MAX(invoices.due_date) ASC')
      .limit(8)
      .pluck(:id)
    
    # Then fetch the full profile records with includes
    @company.profiles
      .by_type('customer')
      .where(id: customer_ids_with_overdue)
      .includes(:invoices)
  end
end 