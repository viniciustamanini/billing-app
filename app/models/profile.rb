class Profile < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :company
  belongs_to :profile_type
  belongs_to :segment, optional: true
  has_many :invoices, dependent: :destroy

  # Renegotiation associations
  has_many :proposed_renegotiations, class_name: "Renegotiation", foreign_key: :proposed_by_profile_id
  has_many :decided_renegotiations, class_name: "Renegotiation", foreign_key: :decided_by_profile_id
  has_many :canceled_renegotiations, class_name: "Renegotiation", foreign_key: :canceled_by_profile_id
  has_many :customer_renegotiations, class_name: "Renegotiation", foreign_key: :customer_profile_id
  
  # Combined renegotiations (all renegotiations where this profile is involved)
  def renegotiations
    Renegotiation.where(
      "proposed_by_profile_id = ? OR decided_by_profile_id = ? OR canceled_by_profile_id = ? OR customer_profile_id = ?",
      id, id, id, id
    )
  end

  validates :first_name, :last_name, presence: true, if: -> { user_id.nil? }

  scope :active, -> { where(active: true) }
  scope :default, -> { where(default_profile: true) }
  scope :by_type, ->(type_name) { joins(:profile_type).where(profile_types: { name: type_name }) }

  after_create :link_user_by_cpf

  def full_name
    if user.present?
      "#{user.first_name} #{user.last_name}"
    else
      "#{first_name} #{last_name}"
    end
  end

  def effective_email
    if user.present?
      user.email
    else
      email
    end
  end

  def customer?
    profile_type.name == "customer"
  end

  private

  def link_user_by_cpf
    return if user.present? || cpf.blank?

    matching_user = User.find_by(cpf: cpf)
    update_column(:user_id, matching_user.id) if matching_user
  end
end
