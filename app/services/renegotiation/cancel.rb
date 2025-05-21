module Renegotiation
  class Cancel
    Result = Struct.new(:success?, :renegotiation, :error)

    def initialize(requester, renegotiation:, params:)
      @renegotiation = renegotiation
      @requester = requester
      @params = params
    end

    def call
      return Result.new(false, @renegotiation, "Not pending") unless @renegotiation.pending
      Result.new(false, @renegotiation, "Only proposer can cancel") unless @renegotiation.proposed_by_profile_id(@requester.id)

      ActiveRecord::Base.transaction do
        @renegotiation.update!(
          renegotiation_status: RenegotiationStatus.canceled,
          cancelled_by_profile: @requester,
          cancellation_date: Time.current,
        )
      end

      Result.new(true, @renegotiation, nil)
    rescue => e
      Result.new(false, @renegotiation, e.message)
    end
  end
end
