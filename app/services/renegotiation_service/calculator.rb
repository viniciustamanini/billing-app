module RenegotiationService
  class Calculator
    Result = Struct.new(
      :total_amount,
      :interest,
      :schedule,
      :installments,
      :proposed_due_date,
      :proposed_total_amount,
      :error,
      keyword_init: true
    )

    def self.call(invoice:, segment:, params:)
      new(invoice, segment, params).call
    end

    def initialize(invoice, segment, params)
      @invoice = invoice
      @segment = segment
      @params = params
    end

    def call
      validate_segment!
      interest = interest_amount
      schedule = build_schedule
      total = @invoice.total_amount + interest

      Result.new(
        total_amount: total,
        interest: interest,
        schedule: schedule,
        installments: @params[:installments].to_i,
        proposed_due_date: schedule.first,
        proposed_total_amount: total,
        error: nil
      )
    rescue StandardError => e
      Rails.logger.error("[Renegotiation::Calculator] #{e.class} - #{e.message}")
      Result.new(error: e.message)
    end

    def interest_amount
      case selected_strategy
      when "settlement_discount"
        discount = safe_decimal(@segment&.discount_percent)
        -(@invoice.total_amount * discount / 100).round(2)
      when "compound"
        raise NotImplementedError, "Compound interest strategy is not supported yet"
      else
        rate = safe_decimal(@segment&.interest_rate)
        months = @params[:installments].to_i.clamp(1, @segment.max_installments)
        ((@invoice.total_amount * (rate / 100)) * months).round(2)
      end
    end

    def build_schedule
      months = @params[:installments].to_i.clamp(1, @segment.max_installments)
      first_due = Date.parse(@params[:proposed_due_date]) rescue @invoice.due_date
      due_dates = []

      case selected_strategy
      when "settlement_discount"
        due_dates << first_due
      else
        months.times do |i|
          due_dates << first_due + i.months
        end
      end

      due_dates
    end

    private

    def parse_date(date)
      return nil if date.blank?
      Date.parse(date.to_s) rescue nil
    end

    def selected_strategy
      @params[:strategy].presence || @segment&.interest_strategy.presence || @invoice.company.default_interest_strategy || "flat_late_fee"
    end

    def self.all_offers(invoice:, segment:)
      (1..segment.max_installments).map do |n|
        calc = call(
          invoice: invoice,
          segment: segment,
          params:  { strategy: strategy_for(segment), installments: n }
        )
        {
          installments:  n,
          total_amount:  calc.total_amount,
          schedule:      calc.schedule,
          code:          "#{segment.id}-#{n}"
        }
      end
    end

    def self.strategy_for(segment)
      segment.interest_strategy.presence || segment.company.default_interest_strategy
    end

    private

    def validate_segment!
      if selected_strategy == "settlement_discount"
        raise "Segment must have a discount percent" if @segment&.discount_percent.nil?
      else
        rate = safe_decimal(@segment&.interest_rate || @invoice.company.default_interest_rate)
        raise "Segment or company must have an interest rate" if rate <= 0
      end
    end

    def safe_decimal(value)
      BigDecimal(value.to_s)
    rescue
      BigDecimal("0")
    end
  end
end
