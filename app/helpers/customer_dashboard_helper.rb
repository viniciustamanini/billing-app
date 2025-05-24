module CustomerDashboardHelper
  def due_date_status_badge(due_date)
    today = Date.current

    if due_date > today
      { title: "A VENCER", class: "bg-green-100 text-green-800" }
    elsif due_date == today
      { title: "VENCE HOJE", class: "bg-yellow-100 text-yellow-800" }
    else
      { title: "VENCIDA", class: "bg-red-100 text-red-800" }
    end
  end
end
