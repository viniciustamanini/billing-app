class CreateInvoiceRenegotiations < ActiveRecord::Migration[8.0]
  def change
    create_table :invoice_renegotiations do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :renegotiation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
