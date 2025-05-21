module Renegotiation
  class Propose
    Result = Struct.new(:success?, :renegotiation, :error)

    def initialize(proposer, invoice:, params:)
      @proposer = proposer
      @invoice = invoice
      @params = params
    end

    def call
      ActiveRecord::Base.transaction do
        reneg = @invoice.build_renegotiation(
          proposed_by_profile: @proposer,
          proposed_total_amount: @params[:proposed_total_amount],
          proposed_due_date: @params[:proposed_due_date],
          reason: @params[:reason],
          installments: @params[:installments],
          renegotiation_status: RenegotiationStatus.pending,
        )

        return Result.new(false, nil, reneg.errors.full_messages.to_sentence) unless reneg.save

        Result.new(true, reneg, nil)
      end
    rescue StandardError => e
      Result.new(false, nil, e.message)
    end
  end
end
