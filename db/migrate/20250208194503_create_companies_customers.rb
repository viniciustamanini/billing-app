class CreateCompaniesCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :companies_customers do |t|
      t.references :company, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
