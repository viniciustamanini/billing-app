class Renegotiation < ApplicationRecord
  belongs_to :renegotiation_status
  belongs_to :proposed_by_profile
  belongs_to :decided_by_profile
  belongs_to :renegotiation_status

  has_many :child_invoices,
        class_name: "Invoice",
        foreign_key: :parent_renegotiation_id,
        iverse_of: :parent_renegotiation

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
