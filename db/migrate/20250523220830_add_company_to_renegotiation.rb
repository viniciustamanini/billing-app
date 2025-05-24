class AddCompanyToRenegotiation < ActiveRecord::Migration[8.0]
  def change
    add_reference :renegotiations, :company, foreign_key: true
  end
end
