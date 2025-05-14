class Profile < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :company
  belongs_to :profile_type

  validates :first_name, :last_name, presence: true, if: -> { user_id.nil? }

  scope :active, -> { where(active: true) }
  scope :default, -> { where(default_profile: true) }
  scope :by_type, ->(type_name) { joins(:profile_type).where(profile_types: { name: type_name }) }

  def full_name
    if user.present?
      "#{user.first_name} #{user.last_name}"
    else
      "#{first_name} #{last_name}"
    end
  end
end
