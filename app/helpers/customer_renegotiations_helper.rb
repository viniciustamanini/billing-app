module CustomerRenegotiationsHelper
  include RenegotiationsHelper
  include InvoicesHelper
  
  def due_date_status_badge(due_date)
    days_overdue = (Date.current - due_date).to_i
    
    if days_overdue > 30
      { class: "bg-red-100 text-red-800", title: "Vencido há mais de 30 dias" }
    elsif days_overdue > 0
      { class: "bg-orange-100 text-orange-800", title: "Vencido há #{days_overdue} dias" }
    elsif days_overdue == 0
      { class: "bg-yellow-100 text-yellow-800", title: "Vence hoje" }
    else
      { class: "bg-green-100 text-green-800", title: "Vence em #{days_overdue.abs} dias" }
    end
  end
end 