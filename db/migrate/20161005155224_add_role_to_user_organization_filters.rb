class AddRoleToUserOrganizationFilters < ActiveRecord::Migration
  def change
    add_reference :user_organization_filters, :created_by_user, index: true
    add_column    :user_organization_filters, :query_string, :text
  end
end
