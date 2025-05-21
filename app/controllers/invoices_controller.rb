class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_profile

  def index
  end

  def new
    @invoice = @profile.invoices.new
    @invoice.invoice_items.build
  end

  def create
    @invoice = @profile.invoices.new(invoice_params)
    if @invoice.save
      redirect_to company_profile_customer_dashboard_path(@company, @profile), notice: "Invoice created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    respond_to do |format|
      format.html
      format.turbo_stream { head :no_content }
    end
  end

  def new_item
    index = Time.now.to_i
    @item = InvoiceItem.new
    render turbo_stream: turbo_stream.append(
      "items",
      partial: "shared/invoice_item_fields",
      locals: { f: build_fake_builder(@item, index) }
    )
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

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def invoice_params
    params.require(:invoice).permit(
      :issued_date, :due_date, :total_amount, :invoice_status_id,
      invoice_items_attributes: [
        :id, :description, :quantity, :unit_price, :_destroy
      ]
    )
  end
end
