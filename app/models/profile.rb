class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :company
  belongs_to :profile_type
end
