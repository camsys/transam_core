class AddTitleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :title, :string, :limit => 64, :after => :last_name
  end
end
