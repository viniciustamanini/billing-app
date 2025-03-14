class DropObsoleteTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :companies_customers, if_exists: true
    drop_table :employees, if_exists: true
    drop_table :customers, if_exists: true
  end
end
