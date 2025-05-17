class AddCompanyToOverdueRanges < ActiveRecord::Migration[8.0]
  def change
    add_reference :overdue_ranges, :company, null: false, foreign_key: true
  end
end
