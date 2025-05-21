%w[customer employee administrator].each do |type|
  ProfileType.find_or_create_by!(name: type)
end

%w[ draft issued sent viewed partial paid overdue void refunded disputed].each do |status|
  InvoiceStatus.find_or_create_by!(name: status)
end

%w[pending approved rejected canceled expired completed].each do |status|
  RenegotiationStatus.find_or_create_by!(name: status)
end

if Rails.env.development?
  default_co = Company.first || Company.create!(name: 'Seed Co', address: '-', city: '-', state: 'NA')

  # 2. Ensure at least one overdue range (0+ days)
  default_range = OverdueRange.first ||
                  OverdueRange.create!(name: 'Padrão', days_from: 0, days_to: nil, company: default_co)

  vip = Segment.find_or_create_by!(name: 'VIP', discount_percent: 25, interest_rate: 0.8, company: default_co, overdue_range: default_range)
  regular = Segment.find_or_create_by!(name: 'Standard', discount_percent: 10, interest_rate: 1.2, company: default_co, overdue_range: default_range)

  Profile.by_type("customer").find_each do |p|
    p.update!(segment: regular) unless p.segment
  end
end
