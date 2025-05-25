module RenegotiationService
  class Cancel
    Result = Struct.new(:success?, :renegotiation, :error)

    def initialize(requester, renegotiation)
      @renegotiation = renegotiation
      @requester = requester
    end

    def call
      return Result.new(false, @renegotiation, "Not pending") unless @renegotiation.pending?
      Result.new(false, @renegotiation, "Only proposer can cancel") unless @renegotiation.proposed_by_profile_id = @requester.id

      Rails.logger.info("Cancelling renegotiation #{@renegotiation.id} by #{@requester.id}")
      ActiveRecord::Base.transaction do
        @renegotiation.update!(
          renegotiation_status: RenegotiationStatus.canceled,
          canceled_by_profile: @requester,
          canceled_at: Time.current,
        )
      end

      Result.new(true, @renegotiation, nil)
    rescue => e
      Result.new(false, @renegotiation, e.message)
    end
  end
end
