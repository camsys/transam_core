class CreateUsersViewableOrganizations < ActiveRecord::Migration
  def change
    create_table :users_viewable_organizations do |t|
      t.integer :user_id
      t.integer :organization_id
    end
  end
end
