class RenegotiationCompletedJob < ApplicationJob
  queue_as :default

  def perform(renegotiation_id)
    reneg = Renegotiation.find(renegotiation_id)
    return unless reneg.approved &&  reneg.child_invoices.all?(&:paid_at)

    reneg.update!(renegotiation_status: RenegotiationStatus.completed)
  end
end
