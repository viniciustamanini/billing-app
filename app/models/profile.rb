class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :company
  belongs_to :profile_type

  scope :active, -> { where(active: true) }
  scope :default, -> { where(default_profile: true) }
  scope :by_type, ->(type_name) { joins(:profile_type).where(profile_types: { name: type_name }) }
end
