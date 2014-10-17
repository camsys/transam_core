class ChangeOrganizationTypeToOrganizationForNotice < ActiveRecord::Migration
  def up
    remove_column :notices, :organization_type_id
    add_reference :notices, :organization, :after => :notice_type_id
  end

  def down
    remove_column :notices, :organization_id
    add_reference :notices, :organization_type
  end
end
