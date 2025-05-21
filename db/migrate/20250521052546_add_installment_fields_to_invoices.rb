class AddInstallmentFieldsToInvoices < ActiveRecord::Migration[8.0]
  def change
    add_reference :invoices, :parent_renegotiation, foreign_key: { to_table: :renegotiations }

    add_column :invoices, :installment_number, :integer
    add_column :invoices, :installment_count, :integer

    add_index :invoices, %i[parent_renegotiation_id installment_number],
              name: :idx_invoices_installments
  end
end
