class RenameDescriptinToDescriptionInSegments < ActiveRecord::Migration[8.0]
  def change
    rename_column :segments, :descriptin, :description
  end
end
