module ApplicationHelper
  include Pagy::Frontend
  include ActionView::Helpers::NumberHelper

  def profile_root_path(profile = nil)
    profile ||= current_user.profiles.find_by(id: session[:active_profile_id])

    return choose_profile_path unless profile

    if customer_profile_type?(profile.profile_type.name)
      customer_dashboard_path()
    else
      company_dashboard_path(profile.company)
    end
  end

  def customer_profile_type?(profile_type)
    profile_type == "customer"
  end

  def admin_profile_type?(profile_type)
    profile_type == "administrator"
  end

  def current_profile_display_name
    return "Dashboard" unless @company_name && @profile_type_display

    if customer_profile_type?(@profile_type)
      "#{@profile_type_display}"
    else
      "#{@profile_type_display} - #{@company_name}"
    end
  end

  def chart_gap_class(dates_count)
    return "gap-4" if dates_count.nil? || dates_count < 0

    case dates_count
    when 0..7
      "gap-6"
    when 8..14
      "gap-4"
    when 15..20
      "gap-3"
    when 21..25
      "gap-2"
    else
      "gap-1"
    end
  end

  def chart_columns_count(dates_count)
    return 0 if dates_count.nil? || dates_count < 0

    case dates_count
    when 0..30
      dates_count
    when 31..60
      30
    else
      30
    end
  end

  def chart_date_format(dates_count, date)
    return "" if date.nil?

    case dates_count
    when 0..7
      date.strftime("%d/%m")
    when 8..14
      date.strftime("%d/%m")
    when 15..20
      date.strftime("%d/%m")
    when 21..30
      date.strftime("%d/%m")
    else
      date.strftime("%d/%m")
    end
  end

  def chart_text_class(dates_count)
    return "text-xs" if dates_count.nil? || dates_count < 0
    
    case dates_count
    when 0..7
      "text-xs"
    when 8..14
      "text-xs"
    when 15..20
      "text-xs"
    when 21..25
      "text-xs text-gray-400"
    else
      "text-xs text-gray-500"
    end
  end

  def chart_max_value(payment_bars)
    return 0 if payment_bars.blank?
    
    max_value = 0
    payment_bars.each do |date, data|
      expected = data[:expected] || 0
      received = data[:received] || 0
      total = expected + received
      max_value = [max_value, total].max
    end
    max_value
  end

  def chart_guide_lines(max_value)
    return [0, 20000, 40000, 60000] if max_value <= 0
    
    rounded_max = ((max_value / 10000.0).ceil * 10000).to_i
    step = rounded_max / 4.0
    
    (0..4).map { |i| (i * step).to_i }
  end

  def format_currency(value)
    "R$ #{number_with_delimiter(value, delimiter: '.', separator: ',')}"
  end

  def chart_bar_height(value, max_value)
    return 0 if max_value <= 0
    ((value.to_f / max_value) * 100).round(2)
  end
end
