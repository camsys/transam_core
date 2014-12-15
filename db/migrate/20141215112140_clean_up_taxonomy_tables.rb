class CleanUpTaxonomyTables < ActiveRecord::Migration
  def change
    remove_column :asset_types,     :status_update_template_name
    remove_column :asset_types,     :disposition_update_template_name
    remove_column :asset_subtypes,  :ali_code
  end
end
