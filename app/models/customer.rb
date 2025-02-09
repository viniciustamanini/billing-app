class Customer < ApplicationRecord
  belongs_to :user
  has_many :companies_customer, dependent: :destroy
  has_many :companies, through: :companies_customer
end
