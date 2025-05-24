class MakeCanceledByProfileNullableInRenegotiations < ActiveRecord::Migration[8.0]
  def change
    change_column_null :renegotiations, :canceled_by_profile_id, true
  end
end
