class MakeDecisionDateNullableInRenegotiations < ActiveRecord::Migration[8.0]
  def change
    change_column_null :renegotiations, :decision_date, true
  end
end
