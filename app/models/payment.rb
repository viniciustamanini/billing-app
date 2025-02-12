class Payment < ApplicationRecord
  belongs_to :invoice
  belongs_to :payment_method
  belongs_to :payment_status
end
