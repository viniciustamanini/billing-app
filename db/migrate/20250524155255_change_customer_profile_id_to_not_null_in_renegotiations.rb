class ChangeCustomerProfileIdToNotNullInRenegotiations < ActiveRecord::Migration[8.0]
  def change
    change_column_null :renegotiations, :customer_profile_id, false
  end
end
