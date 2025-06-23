module RenegotiationService
  class Propose
    Result = Struct.new(:success?, :renegotiation, :error)

    def initialize(proposer, invoice:, segment: nil, params:)
      @proposer = proposer
      @invoice = invoice
      @segment = segment
      @params = params
    end

    def call
      # If no segment provided, use enhanced segmentation logic
      if @segment.nil?
        segment_matcher = SegmentMatcher.new(@invoice.company, @invoice.profile, @invoice.total_amount)
        result = segment_matcher.call
        
        if result.success? && result.segments.any?
          @segment = result.segments.first # Use the first matching segment
        else
          return Result.new(false, nil, "Nenhum segmento aplicável encontrado para este cliente")
        end
      end

      proposed_date = parse_date(@params[:proposed_due_date]) || Date.current
      if proposed_date < Date.current
        return Result.new(false, nil, "Data da renegociação deve ser maior ou igual à data de hoje")
      end

      ActiveRecord::Base.transaction do
        reneg = Renegotiation.create!(
          company: @invoice.company,
          proposed_by_profile: @proposer,
          customer_profile: @invoice.profile,
          proposed_total_amount: @params[:proposed_total_amount],
          proposed_due_date: proposed_date,
          reason: @params[:reason],
          installments: @params[:installments],
          renegotiation_status: RenegotiationStatus.pending,
          segment_id: @segment.id
        )

        InvoiceRenegotiation.create!(invoice: @invoice, renegotiation: reneg)

        total = BigDecimal(@params[:proposed_total_amount].to_s)
        count = @params[:installments].to_i.clamp(1, 60)
        per_installment = (total / count).round(2)

        first_due_date = proposed_date
        due_dates = (0...count).map { |i| first_due_date >> i }

        due_dates.each_with_index do |due_date, index|
          invoice = Invoice.create!(
            profile: @invoice.profile,
            company: @invoice.company,
            total_amount: per_installment,
            due_date: due_date,
            original_due_date: due_date,
            parent_renegotiation_id: reneg.id,
            installment_number: index + 1,
            installment_count: count,
            invoice_status: InvoiceStatus.draft,
            issued_date: Date.current
          )

          invoice.invoice_items.create!(
            description: "Parcela gerada via renegociação",
            quantity: 1,
            unit_price: per_installment,
          )
        end

        Result.new(true, reneg, nil)
      end
    rescue StandardError => e
      Result.new(false, nil, e.message)
    end

    private

    def parse_date(date)
      return nil if date.blank?
      Date.parse(date.to_s) rescue nil
    end
  end
end
