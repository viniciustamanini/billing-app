class CreateEmplyoees < ActiveRecord::Migration[8.0]
  def change
    create_table :emplyoees do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end

    add_index :emplyoees, [ :user_id, :company_id ], unique: true
  end
end
