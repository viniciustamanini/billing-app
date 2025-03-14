class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.references :company, null: false, foreign_key: true, type: :bigint
      t.references :profile_type, null: false, foreign_key: true, type: :bigint
      t.boolean :default_profile, null: false, default: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :profiles, [ :user_id, :company_id, :profile_type_id ],
              unique: true,
              name: 'index_profiles_on_user_company_and_type'

    add_index :profiles, [ :user_id, :company_id ],
              unique: true,
              where: "default_profile = true",
              name: 'unique_default_profile_per_user'
  end
end
