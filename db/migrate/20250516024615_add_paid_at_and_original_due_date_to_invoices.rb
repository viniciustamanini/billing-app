class AddPaidAtAndOriginalDueDateToInvoices < ActiveRecord::Migration[8.0]
  def change
    add_column :invoices, :paid_at, :datetime
    add_column :invoices, :original_due_date, :date

    add_index :invoices, :paid_at
  end
end
