class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.datetime :payment_date, null: false
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.references :payment_method, null: false, foreign_key: true
      t.string :transaction_reference
      t.references :payment_status, null: false, foreign_key: true

      t.timestamps
    end
  end
end
