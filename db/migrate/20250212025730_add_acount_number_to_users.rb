class AddAcountNumberToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :account_number, :uuid, default: -> { "gen_random_uuid()" }, null: false
  end
end
