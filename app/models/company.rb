class Company < ApplicationRecord
  has_many :profiles, dependent: :destroy
  has_many :segments, dependent: :destroy
  has_many :overdue_ranges, dependent: :destroy
  has_many :renegotiations, dependent: :destroy
  has_many :invoices, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
