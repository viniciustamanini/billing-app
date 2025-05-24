class Invoice < ApplicationRecord
  belongs_to :profile
  belongs_to :invoice_status
  belongs_to :parent_renegotiation, optional: true
  belongs_to :company
  has_many :invoice_items, dependent: :destroy

  accepts_nested_attributes_for :invoice_items, allow_destroy: true

  validates :issued_date, :due_date, :total_amount, :profile_id, presence: true

  before_create :set_original_due_date
  after_update :set_due_date_when_partial
  after_update :set_paid_at

  scope :with_status, ->(*keys) {
    joins(:invoice_status).where(invoice_statuses: { name: keys.flatten })
  }

  scope :past_due, -> { where("due_date < ?", Date.current) }
  scope :overdue_status, -> { where(invoice_status: InvoiceStatus.overdue) }

  scope :paid, -> { where(invoice_status: InvoiceStatus.paid) }
  scope :overdue, -> { past_due.or(overdue_status) }
  scope :upcoming, -> { where("due_date >= ?", Date.current) }

  def renegotiated?
    parant_renegotiation_id.present?
  end

  private

  def set_original_due_date
    self.original_due_date = due_date if original_due_date.blank? && due_date.present?
  end

  def set_paid_at
    if invoice_status.name == "paid" && paid_at.nil?
      update_column(:paid_at, Time.current)
    end
  end

  def set_due_date_when_partial
    if invoice_status.name == "partial"
      update_column(:due_date, Date.current)
    end
  end
end
