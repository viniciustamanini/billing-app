class RemoveTaxRateFromInvoiceItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :invoice_items, :tax_rate, :decimal
  end
end
