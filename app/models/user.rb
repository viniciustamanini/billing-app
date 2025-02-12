class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :cpf, presence: true
  validates :cpf, length: { is: 11 }, numericality: { only_integer: true }
  validates_length_of :cpf, is: 11, message: "must have 11 characters"

  has_many :employees, dependent: :destroy
  has_one :customer, dependent: :destroy
end
