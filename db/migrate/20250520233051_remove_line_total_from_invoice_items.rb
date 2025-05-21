class RemoveLineTotalFromInvoiceItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :invoice_items, :line_total, :decimal
  end
end
