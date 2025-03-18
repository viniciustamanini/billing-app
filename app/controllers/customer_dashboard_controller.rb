class CustomerDashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    profile_type = ProfileType.find_by(name: "customer")

    @user_profiles = current_user.profiles.where(profile_type: profile_type)

    @invoices = {}
    @upcoming_invoices = {}
    @payment_history = {}

    @user_profiles.each do |profile|
      # TODO should filter by invoice status
      invoices = Invoice.where(profile_id: profile.id).order(due_date: :asc)
      @invoices[profile.id] = invoices

      @upcoming_invoices[profile.id] = invoices.select { |invoice| invoice.due_date >= Date.today }

      payment_history = Payment.joins(:invoice).where(invoices: { profile_id: profile.id }).order(created_at: :desc)
      @payment_history[profile.id] = payment_history
    end
  end
end
