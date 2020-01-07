class ShowQuantityUnitsInQueryTool < ActiveRecord::DataMigration
  def up
    field_params = {name: 'quantity_unit', label: 'Quantity Units', query_category: QueryCategory.find_by(name: 'Characteristics'), filter_type: 'text'}
    field = QueryField.find_by(field_params)

    if field
      field.update!(hidden: false)
    else
      field.create!(field_params)
    end
  end
end