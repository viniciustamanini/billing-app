module Renegotiation
  class Calculator
    Result = Struct.new(:total_amount, :interest, :schedule, :error, keyword_init: true)

    def self.call(invoice:, segment:, params:)
      new(invoice, segment, params).call
    end

    def initialize(invice, segment, params)
      @invoice = invice
      @segment = segment
      @params = params
    end

    def call
      interest = interest_amount
      schedule = build_schedule

      Result.new(
        total_amount: @invoice.total_amount + interest,
        interest: interest,
        schedule: schedule,
        error: nil
      )

    rescue StandardError => e
      Result.new(error: e.message)
    end

    def interest_amount
      rule = build_interest_rule
      strategy = InterestStrategy.for(rule)
      strategy.interest_on(@invoice)
    end

    def build_interest_rule
      case selected_strategy
      when "settlement_discount"
        {
          strategy: "settlement_discount",
          discount: @segment&.discount_percent.to_d
        }
      else
        {
          strategy: "flat_late_fee",
          monthly_rate: @segment&.interest_rate.presence || @invoice.company.default_monthly_rate
        }
      end
    end

    def selected_strategy
      @params[:strategy].presence || @segment&.interest_strategy || "flat_late_fee"
    end

    def build_schedule
      sched_strategy = case selected_strategy
      when "settlement_discount" then "bullet_payment"
      else                          "equal_installments"
      end

      ScheduleStrategy.for(sched_strategy)
                      .schedule(@invoice, (@params[:installments] || 1))
    end
  end
end
