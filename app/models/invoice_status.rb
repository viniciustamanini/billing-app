class InvoiceStatus < ApplicationRecord
  has_many :invoices

  validates :name, presence: true, uniqueness: true

  def self.paid
    find_by!(name: "paid")
  end

  def self.overdue
    find_by!(name: "overdue")
  end

  def self.issued
    find_by!(name: "issued")
  end
end
