class Profile < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :company
  belongs_to :profile_type

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

  private

  def link_user_by_cpf
    return if user.present? || cpf.blank?

    matching_user = User.find_by(cpf: cpf)
    update_column(:user_id, matching_user.id) if matching_user
  end
end
