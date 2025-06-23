class OverdueRange < ApplicationRecord
  belongs_to :company

  validates :days_to, :days_from, presence: true
  validate :days_from_before_days_to
  validate :no_overlap_with_existing_ranges

  scope :active, -> { where(active: true) }
  scope :display_order, -> {
      order(active: :desc).order(:days_from)
  }

  private

  def days_from_before_days_to
    return if days_from.blank? || days_to.blank?
    errors.add(:days_to, "Deve ser maior que os dias de") if days_to <= days_from
  end

  def no_overlap_with_existing_ranges
    return unless company.present? && days_from.present? && days_to.present?

    overlapping_ranges = company.overdue_ranges
      .active
      .where.not(id: id)
      .where("days_from <= ? AND days_to >= ?", days_to, days_from)

    if overlapping_ranges.exists?
      errors.add(:base, "Ja existem faixas neste periodo.")
    end
  end
end
