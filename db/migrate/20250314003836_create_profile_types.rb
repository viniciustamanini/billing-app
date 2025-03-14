class CreateProfileTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :profile_types do |t|
      t.string :name, null: false, limit: 20
      t.timestamps
    end

    add_index :profile_types, :name, unique: true

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          INSERT INTO profile_types (name, created_at, updated_at)
          VALUES ('customer', NOW(), NOW()),
                 ('employee', NOW(), NOW()),
                 ('administrator', NOW(), NOW())
        SQL
      end
    end
  end
end
