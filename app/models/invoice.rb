class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :invoice_status
end
