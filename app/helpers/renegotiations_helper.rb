module RenegotiationsHelper
  def status_badge_class(status_name)
    {
      RenegotiationStatus.approved.name => "bg-green-100 text-green-800",
      RenegotiationStatus.rejected.name => "bg-red-100 text-red-800",
      RenegotiationStatus.pending.name  => "bg-yellow-100 text-yellow-800"
    }[status_name] || "bg-gray-100 text-gray-800"
  end

  def renegotiation_status_options
    [ [ t("all"), "all" ] ] +
      RenegotiationStatus.order(:name).map do |status|
        [ renegotiation_status_translation(status), status.id ]
      end
  end

  def renegotiation_status_translation(renegotiation_status)
    I18n.t("activerecord.attributes.renegotiation_status.#{renegotiation_status.name}")
  end
end
