class AddSegmentToRenegotiations < ActiveRecord::Migration[8.0]
  def change
    add_reference :renegotiations, :segment, null: false, foreign_key: true
  end
end
