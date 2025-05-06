class AddCpfToProfilesAndMakeUserIdNullable < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :cpf, :string, limit: 11
    add_index :profiles, :cpf

    change_column_null :profiles, :user_id, true
  end
end
