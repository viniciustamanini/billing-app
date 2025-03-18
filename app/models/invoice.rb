class Invoice < ApplicationRecord
  belongs_to :profile
  belongs_to :invoice_status
end
