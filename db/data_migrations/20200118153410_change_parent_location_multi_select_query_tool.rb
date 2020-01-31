class ChangeParentLocationMultiSelectQueryTool < ActiveRecord::DataMigration
  def up
    QueryField.where(name: ['parent_id', 'location_id']).update_all(filter_type: 'multi_select')
  end
end