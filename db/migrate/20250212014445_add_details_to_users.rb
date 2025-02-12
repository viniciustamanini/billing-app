class AddDetailsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string, limit: 50, null: false
    add_column :users, :last_name, :string, limit: 100, null: false
    add_column :users, :cpf, :string, limit: 11, null: false
  end
end
