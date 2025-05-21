class AddDiscountPercentToSegments < ActiveRecord::Migration[8.0]
  def change
    add_column :segments, :discount_percent, :decimal, precision: 6, scale: 3, default: 0.0
  end
end
