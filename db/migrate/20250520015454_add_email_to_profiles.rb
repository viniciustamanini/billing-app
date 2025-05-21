class AddEmailToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :email, :string,  null: false, default: ""
  end
end
