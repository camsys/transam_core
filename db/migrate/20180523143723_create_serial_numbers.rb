class CreateSerialNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :serial_numbers do |t|
      t.references :identifiable, polymorphic: true
      t.string :identification
    end
  end
end
