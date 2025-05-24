class AddCompanyToInvoices < ActiveRecord::Migration[8.0]
  def change
    add_reference :invoices, :company, foreign_key: true, index: true

    execute <<~SQL.squish
      UPDATE invoices
         SET company_id = profiles.company_id
        FROM profiles
       WHERE profiles.id = invoices.profile_id
    SQL

    change_column_null :invoices, :company_id, false
  end
end
