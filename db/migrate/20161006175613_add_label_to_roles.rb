class AddLabelToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :label, :string
  end
end
