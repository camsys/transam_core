class AddRoleToUserOrganizationFilters < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists?(:user_organization_filters)
      add_reference :user_organization_filters, :created_by_user, index: true
      add_column    :user_organization_filters, :query_string, :text
      remove_column :user_organization_filters, :user_id

      create_table :users_user_organization_filters do |t|
        t.references :user,           null: false
        t.references :user_organization_filter,   null: false
      end

      add_index :users_user_organization_filters, :user_id, name: 'users_user_organization_filters_idx1'
      add_index :users_user_organization_filters, :user_organization_filter_id, name: 'users_user_organization_filters_idx2'
    end
  end
end
