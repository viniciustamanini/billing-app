class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_profile
  before_action :set_invoice, only: %i[edit update]

  def index
  end

  def new
    @invoice = @profile.invoices.new
    @invoice.invoice_items.build
  end

  def create
    @invoice = @profile.invoices.new(invoice_params)
    @invoice.company = @company
    if @invoice.save
      redirect_to company_profile_customer_dashboard_path(@company, @profile), notice: "Invoice created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @invoice = @profile.invoices.includes(:invoice_items, :invoice_status).find(params[:id])
  end

  def new_item
    index = Time.now.to_i + rand(1000)
    @item = InvoiceItem.new
    render turbo_stream: turbo_stream.append(
      "items",
      partial: "shared/invoice_item_fields",
      locals: { f: build_fake_builder(@item, index) }
    )
  end

  def edit
  end

  def update
    if @invoice.update(invoice_due_date_params)
      redirect_to company_profile_invoice_path(@company, @profile, @invoice), notice: "Successfully updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def build_fake_builder(item, index)
    ActionView::Helpers::FormBuilder.new(
      "invoice[invoice_items_attributes][#{index}]",
      item,
      view_context,
      {},
    )
  end

  def set_invoice
    @invoice = @profile.invoices.find(params[:id])
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def invoice_params
    params.require(:invoice).permit(
      :issued_date, :due_date, :total_amount, :invoice_status_id, :company_id,
      invoice_items_attributes: [
        :id, :description, :quantity, :unit_price, :_destroy
      ]
    )
  end

  def invoice_due_date_params
    params.require(:invoice).permit(:due_date)
  end
end
