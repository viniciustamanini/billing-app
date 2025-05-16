class CustomerDashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @profile_type = ProfileType.customer.name
    profiles = current_user.profiles.where(profile_type: ProfileType.customer)
    profile_ids = profiles.pluck(:id)

    @recurring_payment_day = current_user.recurring_payment_day()
    @invoices = Invoice
      .includes(:invoice_status, :profile)
      .where(profile_id: profile_ids)
      .order(:due_date)

    # TODO add a filter by invoice status
    @overdue_invoices = @invoices.overdue
    @upcoming_invoices = @invoices.upcoming
    @paid_invoices = @invoices.paid
    @paid_invoices_value = @paid_invoices.sum(:total_amount)
    @upcoming_invoices_value = @upcoming_invoices.sum(:total_amount)

    overdue_min_date = @overdue_invoices.minimum(:due_date)
    @days_most_overdue = overdue_min_date ? (Date.current - overdue_min_date).to_i : 0
    @status = @days_most_overdue.positive? ? "Em atraso" : "Em dia"

    @payment_history = Payment
      .joins(:invoice)
      .where(invoices: { profile_id: profile_ids })
      .order(created_at: :desc)
  end
end
