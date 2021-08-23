class AddExecutiveDirectorToOrgs < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :executive_director_id, :integer
    add_index :organizations, :executive_director_id
  end
end
