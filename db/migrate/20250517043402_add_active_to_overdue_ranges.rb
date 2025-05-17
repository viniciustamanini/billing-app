class AddActiveToOverdueRanges < ActiveRecord::Migration[8.0]
  def change
    add_column :overdue_ranges, :active, :boolean, null: false, default: true
  end
end
