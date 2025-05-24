module RenegotiationsHelper
  def status_badge_class(status_name)
    {
      "approved" => "bg-green-100 text-green-800",
      "rejected" => "bg-red-100 text-red-800",
      "pending"  => "bg-yellow-100 text-yellow-800"
    }[status_name] || "bg-gray-100 text-gray-800"
  end

  def renegotiation_status_options
    [ [ "Todos", "all" ] ] +
      RenegotiationStatus.order(:name).pluck(:name, :id).map do |name, id|
        [ t("renegotiation_statuses.#{name}"), id ]
      end
  end
end
