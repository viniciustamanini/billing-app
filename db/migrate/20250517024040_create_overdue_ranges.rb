class CreateOverdueRanges < ActiveRecord::Migration[8.0]
  def change
    create_table :overdue_ranges do |t|
      t.string :name
      t.column :days_from, :smallint
      t.column :days_to, :smallint

      t.timestamps
    end
  end
end
