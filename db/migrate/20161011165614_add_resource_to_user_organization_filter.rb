class AddResourceToUserOrganizationFilter < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.table_exists?(:user_organization_filters)
      change_table :user_organization_filters do |t|
        t.references :resource, :polymorphic => true
      end
    end
  end

  def down
    if ActiveRecord::Base.connection.table_exists?(:user_organization_filters)
      change_table :user_organization_filters do |t|
        t.remove_references :resource, :polymorphic => true
      end
    end
  end
end
