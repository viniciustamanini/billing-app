class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.date :issued_date, null: false
      t.date :due_date, null: false
      t.decimal :total_amount, null: false, precision: 10, scale: 2
      t.references :invoice_status, null: false, foreign_key: true

      t.timestamps
    end
  end
end
