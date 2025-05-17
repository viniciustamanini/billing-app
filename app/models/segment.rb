class Segment < ApplicationRecord
  belongs_to :company
  belongs_to :overdue_range
end
