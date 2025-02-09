class Company < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  has_many :employees, dependent: :destroy
  has_many :companies_customers, dependent: :destroy
  has_many :customers, through: :companies_customers
end
