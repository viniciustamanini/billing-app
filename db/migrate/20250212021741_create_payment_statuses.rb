class CreatePaymentStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_statuses do |t|
      t.string :name, null: false, limit: 30

      t.timestamps
    end
  end
end
