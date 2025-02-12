class CreateRenegotiations < ActiveRecord::Migration[8.0]
  def change
    create_table :renegotiations do |t|
      t.decimal :proposed_total_amount, null: false, precision: 10, scale: 2
      t.date :proposed_due_date, null: false
      t.text :reason, limit: 1000
      t.references :renegotiation_status, null: false, foreign_key: true
      t.date :decision_date, null: false
      t.text :notes, limit: 1000

      t.timestamps
    end
  end
end
