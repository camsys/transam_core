class FixOrganizationQueryFields < ActiveRecord::DataMigration
  def up
    # Establish new QueryAssociationClasses (QAC)
    vendor_qac = QueryAssociationClass.find_or_create_by(table_name: 'vendors', display_field_name: 'name',
                                                         id_field_name: 'id', use_field_name: false)
    field_name_qac = QueryAssociationClass.find_or_create_by(table_name: 'organizations_with_others_view',
                                                             display_field_name: 'short_name', id_field_name: 'id',
                                                             use_field_name: true)
    
    # Connect Vendor QueryField to Vendor QAC
    vendor_qf = QueryField.find_by(label: 'Vendor')
    vendor_qf.query_association_class = vendor_qac
    vendor_qf.save!
    
    # Connect Lienholder and Title Holder QueryFields to "use_field_name" QAC
    lienholder_qf = QueryField.find_by(label: 'Lienholder')
    title_qf = QueryField.find_by(label: 'Title Holder')

    lienholder_qf.query_association_class = field_name_qac
    title_qf.query_association_class = field_name_qac

    lienholder_qf.save!
    title_qf.save!
  end
end
