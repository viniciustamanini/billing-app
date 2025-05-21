class RenegotiationStatus < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  STATUS_CODES = %w[pending approved rejected canceled expired completed].freeze
  STATUS_CODES.each do |code|
    define_singleton_method(code) { find_by(name: code) }
  end
end
