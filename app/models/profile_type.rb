class ProfileType < ApplicationRecord
  has_many :profiles

  def self.admin
    find_by!(name: "administrator")
  end

  def self.employee
    find_by!(name: "employee")
  end

  def self.customer
    find_by!(name: "customer")
  end
end
