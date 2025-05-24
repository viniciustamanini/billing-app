class AddMaxInstallmentsToSegments < ActiveRecord::Migration[8.0]
  def change
    add_column :segments, :max_installments, :integer, null: false, default: 1
  end
end
