class UpdateInvoicesForProfiles < ActiveRecord::Migration[8.0]
  def change
    add_reference :invoices, :profile, null: false, foreign_key: true, type: :bigint
  end
end
