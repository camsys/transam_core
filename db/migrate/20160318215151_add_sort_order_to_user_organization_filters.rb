class AddSortOrderToUserOrganizationFilters < ActiveRecord::Migration
  def change
    add_column :user_organization_filters, :sort_order, :integer
  end
end
