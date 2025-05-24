class AddInstallmentsToRenegotiations < ActiveRecord::Migration[8.0]
  def change
    add_column :renegotiations, :installments, :integer, null: false
  end
end
