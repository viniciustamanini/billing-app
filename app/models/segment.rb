class Segment < ApplicationRecord
  belongs_to :company
  belongs_to :overdue_range
  has_many :profiles

  STRATEGIES = %w[flat_late_fee settlement_discount compound].freeze

  validate :debt_max_greater_than_debt_min
  validate :validate_interest_rate_for_strategy
  validates :interest_rate, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 100.0 }
  validates :discount_percent, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 100.0 }
  validates :interest_strategy, inclusion: { in: STRATEGIES }

  scope :active, -> { where(active: true) }

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
    errors.add(:debt_max, :must_be_greater) if debt_min > debt_max
  end

  def validate_interest_rate_for_strategy
    return if interest_strategy == "settlement_discount"
    return if interest_rate.present? && interest_rate.positive?
    
    errors.add(
      :interest_rate, 
      :strategy_requires_interest_rate, 
      strategy: I18n.t("segment_strategies.#{interest_strategy}")
    )
  end
end
