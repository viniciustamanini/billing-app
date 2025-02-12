class CreateInvoiceStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :invoice_statuses do |t|
      t.string :name, limit: 50, null: false

      t.timestamps
    end
    add_index :invoice_statuses, :name, unique: true
  end
end
