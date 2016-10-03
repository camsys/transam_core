class RemoveDefaults < ActiveRecord::Migration
  def change
    change_column_default :issues, :issue_status_type_id, nil
    change_column_default :funding_sources, :description, nil
    change_column_default :fta_funding_source_types, :active, nil
  end
end
