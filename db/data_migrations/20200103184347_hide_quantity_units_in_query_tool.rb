class HideQuantityUnitsInQueryTool < ActiveRecord::DataMigration
  def up
    field = QueryField.find_by(name: 'quantity_unit')

    if field
      field.update!(hidden: true)
    end
  end
end