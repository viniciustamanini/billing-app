class Segment < ApplicationRecord
  belongs_to :company
  belongs_to :overdue_range

  validate :debt_max_greater_than_debt_min

  private

  def debt_max_greater_than_debt_min
    return if debt_min.blank? || debt_max.blank?
    errors.add(:debt_max, "must be greater than debt min") if debt_min > debt_max
  end
end
