class CreateConditionTypePercents < ActiveRecord::Migration
  def change
    create_table :condition_type_percents do |t|
      t.references :asset_event, index: true
      t.references :condition_type, index: true
      t.integer :pcnt

      t.timestamps
    end
  end
end
