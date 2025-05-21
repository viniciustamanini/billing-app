class ExpirePendingRenegotiationsJob < ApplicationJob
  queue_as :default

  def perform
    # TODO maybe the days ago will be set by companie settings
    Renegotiation
      .pending
      .where("renegotiatins.proposed_due_date < ?", 10.days.ago)
  end
end
