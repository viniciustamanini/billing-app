class AddInterestRulesToSegments < ActiveRecord::Migration[8.0]
  def change
    add_column :segments, :interest_rate, :decimal, precision: 6, scale: 3, default: 0.0
    add_column :segments, :interest_stategy, :string, default: "simple"

    add_column :companies, :default_interest_rate, :decimal, precision: 6, scale: 3, default: 0.0
    add_column :companies, :default_interest_strategy, :string, default: "simple"
  end
end
