class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :cpf, presence: true
  validates :cpf, length: { is: 11 }, numericality: { only_integer: true }
  validates_length_of :cpf, is: 11, message: "must have 11 characters"

  has_many :profiles, dependent: :destroy

  after_create :link_profiles

  def full_name
    "#{first_name} #{last_name}"
  end

  def recurring_payment_day(as_of: Date.current)
    customer_ids = profiles.find_by(profile_type: ProfileType.customer)

    return nil if customer_ids.blank?

    Invoice
      .joins(:invoice_status)
      .where(profile_id: customer_ids, invoice_statuses: { name: "paid" })
      .where("paid_at <= ?", as_of)
      .group("EXTRACT(DAY FROM paid_at)")
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(1)
      .pluck(Arel.sql("EXTRACT(DAY FROM paid_at)::int"))
      .first
  end

  private

  def link_profiles
    Profile.where(cpf: cpf, user_id: nil).update_all(user_id: id)
  end
end
