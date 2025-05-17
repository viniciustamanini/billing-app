class CreateSegments < ActiveRecord::Migration[8.0]
  def change
    create_table :segments do |t|
      t.references :company, null: false, foreign_key: true
      t.references :overdue_range, null: false, foreign_key: true
      t.string :name
      t.text :descriptin
      t.decimal :debt_min
      t.decimal :debt_max
      t.boolean :include_active_customer
      t.boolean :include_inactive_customer
      t.boolean :active

      t.timestamps
    end
  end
end
