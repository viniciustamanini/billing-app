class AddCustomerProfileToRenegotiations < ActiveRecord::Migration[8.0]
  def change
    add_reference :renegotiations, :customer_profile, foreign_key: { to_table: :profiles }, index: true
  end
end
