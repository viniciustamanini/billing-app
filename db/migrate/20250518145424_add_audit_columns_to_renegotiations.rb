class AddAuditColumnsToRenegotiations < ActiveRecord::Migration[8.0]
  def change
    change_table :renegotiations, bulk: true do |t|
      t.references :proposed_by_profile,
                   null: false,
                   foreign_key: { to_table: :profiles }

      t.references :decided_by_profile,
                   foreign_key: { to_table: :profiles }

      t.references :canceled_by_profile,
                   null: false,
                   foreign_key: { to_table: :profiles }

      t.decimal  :original_total_amount, precision: 10, scale: 2
      t.datetime :paid_at
      t.datetime :expired_at
      t.datetime :canceled_at
      t.datetime :completed_at
    end
  end
end
