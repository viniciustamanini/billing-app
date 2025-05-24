class FixInterestStrategyColumnNameOnSegments < ActiveRecord::Migration[8.0]
  def change
    rename_column :segments, :interest_stategy, :interest_strategy
    change_column_default :segments, :interest_strategy, from: 'simple', to: 'flat_late_fee'
  end
end
