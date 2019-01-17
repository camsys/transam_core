class AddSavedQueryOrganizationsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations_saved_queries do |t|
      t.references :saved_query,          null: false, index: true
      t.references :organization,         null: false, index: true

      t.timestamps
    end
  end
end
