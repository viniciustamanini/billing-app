module Renegotiation
  class Reject
    Result = Struct.new(:success?, :renegotiation, :error)

    def initialize(decider, renegotiation:, params:)
      @decider = decider
      @renegotiation = renegotiation
      @params = params
    end

    def call
      return Result.new(false, @renegotiation, "Not pending") unless @renegotiation.pending
      return Result.new(false, @renegotiation, "You are the proposer") unless @renegotiation.decision_perding_for?(@decider)

      @renegotiation.update!(
        renegotiation_status: RenegotiationStatus.rejected,
        decided_by_profile: @decider,
        decision_date: Time.current,
      )

      Result.new(true, @renegotiation, nil)
    rescue => e
      Result.new(false, @renegotiation, e.message)
    end
  end
end
