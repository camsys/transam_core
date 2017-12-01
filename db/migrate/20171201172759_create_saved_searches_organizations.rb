class CreateSavedSearchesOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations_saved_searches do |t|
      t.references :organization,           index: true
      t.references :saved_search,       index: true
    end
  end
end
