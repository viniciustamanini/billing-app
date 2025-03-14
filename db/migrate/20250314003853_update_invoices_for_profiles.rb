class UpdateInvoicesForProfiles < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :invoices, column: :customer_id
    remove_index :invoices, :customer_id if index_exists?(:invoices, :customer_id)
    remove_column :invoices, :customer_id, :bigint

    add_reference :invoices, :profile, null: false, foreign_key: true, type: :bigint
  end
end
