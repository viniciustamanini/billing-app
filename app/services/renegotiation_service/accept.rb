module RenegotiationService
  class Accept
    Result = Struct.new(:success?, :renegotiation, :error)

    def initialize(decider, renegotiation:, params:)
      @renegotiation = renegotiation
      @decider = decider
    end

    def call
      return Result.new(false, @renegotiation, "Not pending") unless @renegotiation.pending
      return Result.new(false, @renegotiation, "You are the proposer") unless @renegotiation.decision_perding_for?(@decider)

      ActiveRecord::Base.transaction do
        @renegotiation.update!(
          renegotiation_status: RenegotiationStatus.approved,
          decided_by_profile: @decider,
          decision_date: Time.current,
        )
        Splitter.new(@renegotiation).call
      end

      Result.new(true, @renegotiation, nil)
    rescue => e
      Result.new(false, @renegotiation, e.message)
    end
  end
end
