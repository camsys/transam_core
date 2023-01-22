class FixOperatorQueryField < ActiveRecord::DataMigration
  def up
    field_name_qac = QueryAssociationClass.find_or_create_by(table_name: 'organizations_with_others_view',
                                                             display_field_name: 'short_name', id_field_name: 'id',
                                                             use_field_name: true)

    # Connect Operator to "use_field_name" QAC
    operator_qf = QueryField.find_by(label: 'Operator')
    operator_qf.query_association_class = field_name_qac
    operator_qf.save!

  end
end
