class AddParentToPolicy < ActiveRecord::Migration
  def change
    # Add a parent index field to policy so it can act as a tree
    add_column    :policies, :parent_id, :integer, :after => :organization_id
    
  end
end
