class InvoiceRenegotiation < ApplicationRecord
  belongs_to :invoice
  belongs_to :renegotiation
end
