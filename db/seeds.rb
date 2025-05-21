# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

invoice_statuses = %w[
  draft issued sent viewed partial paid overdue void refunded disputed
]

invoice_statuses.each do |status|
  InvoiceStatus.find_or_create_by!(name: status)
end

renegotiation_statuses = %w[
  pending approved rejected canceled expired completed
]

renegotiation_statuses.each do |status|
  RenegotiationStatus.find_or_create_by!(name: status)
end
