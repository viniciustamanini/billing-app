module RenegotiationService
  class Cancel
    Result = Struct.new(:success?, :renegotiation, :error)

    def initialize(requester, renegotiation)
      @renegotiation = renegotiation
      @requester = requester
    end

    def call
      return Result.new(false, @renegotiation, "Renegociação não está pendente") unless @renegotiation.pending?
      return Result.new(false, @renegotiation, "Apenas o proponente pode cancelar") unless @renegotiation.proposed_by_profile_id == @requester.id

      Rails.logger.info("Cancelling renegotiation #{@renegotiation.id} by #{@requester.id}")
      ActiveRecord::Base.transaction do
        # Delete child invoices since the renegotiation was canceled
        @renegotiation.child_invoices.destroy_all
        
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
