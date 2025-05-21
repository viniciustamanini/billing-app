class InvoiceItem < ApplicationRecord
  belongs_to :invoice

  validates :description, :quantity, :unit_price, presence: true

  def total_price
    quantity * unit_price
  end
end
