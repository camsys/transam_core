class AddResourceToUserOrganizationFilter < ActiveRecord::Migration
  def up
    change_table :user_organization_filters do |t|
      t.references :resource, :polymorphic => true
    end
  end

  def down
    change_table :user_organization_filters do |t|
      t.remove_references :resource, :polymorphic => true
    end
  end
end
