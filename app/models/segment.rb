class Segment < ApplicationRecord
  belongs_to :company
  belongs_to :overdue_range

  STRATEGIES = %w[flat_late_fee settlement_discount compound].freeze

  validate :debt_max_greater_than_debt_min
  validates :interest_rate, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 100.0 }
  validates :discount_percent, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 100.0 }

  def interest_rule
    {
      stragety: interest_strategy,
      rate: interest_rate,
      discount: discount_percent
    }
  end

  private

  def debt_max_greater_than_debt_min
    return if debt_min.blank? || debt_max.blank?
    errors.add(:debt_max, "must be greater than debt min") if debt_min > debt_max
  end
end
