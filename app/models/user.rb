class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :cpf, presence: true
  validates :cpf, length: { is: 11 }, numericality: { only_integer: true }
  validates_length_of :cpf, is: 11, message: "must have 11 characters"

  has_many :profiles, dependent: :destroy

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def link_profiles
    Profile.where(cpf: cpf, user_id: nil).update_all(user_id: id)
  end
end
