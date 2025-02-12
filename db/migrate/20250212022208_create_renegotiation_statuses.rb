class CreateRenegotiationStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :renegotiation_statuses do |t|
      t.string :name, null: false, limit: 30

      t.timestamps
    end
    add_index :renegotiation_statuses, :name, unique: true
  end
end
