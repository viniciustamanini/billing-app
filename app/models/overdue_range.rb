class OverdueRange < ApplicationRecord
  belongs_to :company

  validate :no_overlap_with_existing_ranges

  private

  def no_overlap_with_existing_ranges
    return unless company.present? && days_from.present? && days_to.present?

    overlapping_ranges = company.overdue_ranges
      .where.not(id: id)
      .where("days_from <= ? AND days_to >= ?", days_to, days_from)

    if overlapping_ranges.exists?
      errors.add(:base, "This range overlaps with existing ranges.")
    end
  end
end
