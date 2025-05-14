class AddNamesToProfile < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :first_name, :string, limit: 50, null: true
    add_column :profiles, :last_name, :string, limit: 100, null: true
  end
end
