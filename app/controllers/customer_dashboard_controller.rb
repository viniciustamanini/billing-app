class CustomerDashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: %i[index_for_company]

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

  def index_for_company
    customer_profile = @company.profiles
      .left_joins(:user)
      .by_type("customer")
      .find_by!(id: params[:profile_id])

    @customer_name = customer_profile.full_name
    @customer_email = customer_profile.effective_email

    unless current_profile.company_id == @company.id
      redirect to company_dashboard_path(@company),
      flash: { error: "Nao autorizado." } and return
    end

    @invoices = Invoice
      .includes(:invoice_status, profile: :company)
      .where(profile_id: customer_profile.id)
      .order(:due_date)

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
      .where(invoices: { profile_id: customer_profile.id })
      .order(created_at: :desc)
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end
end
