class FixOrgFaxCharLimit < ActiveRecord::Migration[5.2]
  def change
    change_column :organizations, :fax, :string, limit: 12
  end
end
