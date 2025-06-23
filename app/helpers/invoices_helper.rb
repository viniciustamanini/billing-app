module InvoicesHelper
  def invoice_status_translation(invoice_status)
    I18n.t("invoice_statuses.#{invoice_status.name}")
  end
end
