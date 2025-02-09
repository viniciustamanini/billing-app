class RenameEmplyoeesToEmployees < ActiveRecord::Migration[8.0]
  def change
    rename_table :emplyoees, :employees
  end
end
