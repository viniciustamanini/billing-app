module RenegotiationService
  class Reject
    Result = Struct.new(:success?, :renegotiation, :error)

    def initialize(decider, renegotiation)
      @decider = decider
      @renegotiation = renegotiation
    end

    def call
      return Result.new(false, @renegotiation, "Renegociação não está pendente") unless @renegotiation.pending?
      return Result.new(false, @renegotiation, "Você é o proponente") unless @renegotiation.decision_perding_for?(@decider)

      ActiveRecord::Base.transaction do
        # Delete child invoices since the renegotiation was rejected
        @renegotiation.child_invoices.destroy_all
        
        @renegotiation.update!(
          renegotiation_status: RenegotiationStatus.rejected,
          decided_by_profile: @decider,
          decision_date: Time.current,
        )
      end

      Result.new(true, @renegotiation, nil)
    rescue => e
      Result.new(false, @renegotiation, e.message)
    end
  end
end
