class UpdateConditionRatingCeilings < ActiveRecord::DataMigration
  def up
    ConditionType.find_by(name: 'Unknown').update!(rating_ceiling: 0.99)
    ConditionType.find_by(name: 'Poor').update!(rating_ceiling: 1.94)
    ConditionType.find_by(name: 'Marginal').update!(rating_ceiling: 2.94)
    ConditionType.find_by(name: 'Adequate').update!(rating_ceiling: 3.94)
    ConditionType.find_by(name: 'Good').update!(rating_ceiling: 4.74)
    ConditionType.find_by(name: 'New/Excellent').update!(name: 'Excellent', rating_ceiling: 5.00)
  end
end