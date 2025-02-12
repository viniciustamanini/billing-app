class CreateInvoiceItems < ActiveRecord::Migration[8.0]
  def change
    create_table :invoice_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.text :description, limit: 250
      t.integer :quantity, null: false, precision: 10, scale: 2
      t.decimal :unit_price, null: false, precision: 10, scale: 2
      t.decimal :tax_rate, null: false, precision: 10, scale: 2
      t.decimal :line_total, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
