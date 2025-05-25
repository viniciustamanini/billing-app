class Renegotiation < ApplicationRecord
  belongs_to :renegotiation_status
  belongs_to :proposed_by_profile, class_name: "Profile"
  belongs_to :decided_by_profile, class_name: "Profile", optional: true
  belongs_to :canceled_by_profile, class_name: "Profile", optional: true
  belongs_to :customer_profile, class_name: "Profile"
  belongs_to :company
  belongs_to :segment

  has_many :child_invoices,
        class_name: "Invoice",
        foreign_key: :parent_renegotiation_id,
        inverse_of: :parent_renegotiation

  validates :installments, numericality: { only_integer: true, greater_than: 0 }

  RenegotiationStatus::STATUS_CODES.each do |code|
    scope code, -> {
        joins(:renegotiation_status)
        .where(renegotiation_statuses: { name: code })
    }
  end

  delegate :name, to: :renegotiation_status, prefix: :status
  delegate :customer?, to: :proposed_by_profile, prefix: :proposer

  def decision_perding_for?(profile)
    status_name == "pending" && (profile.customer? ^ proposer_customer?)
  end
end
