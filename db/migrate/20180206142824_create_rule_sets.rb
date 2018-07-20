class CreateRuleSets < ActiveRecord::Migration[5.2]
  def change
    create_table :rule_sets do |t|
      t.string :object_key
      t.string :name
      t.string :class_name
      t.boolean :rule_set_aware
      t.boolean :active
    end
  end
end
