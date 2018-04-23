class AddRuleSets < ActiveRecord::DataMigration
  def up
    RuleSet.create!(name: 'Asset Replacement/Rehabilitation Policy', class_name: 'Policy', rule_set_aware: false, active: true)
  end

  def down
    RuleSet.destroy_all
  end
end