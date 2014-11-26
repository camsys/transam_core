class AddAddressFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :address1, :string, :limit => 32, :after => :email
    add_column :users, :address2, :string, :limit => 32, :after => :address1
    add_column :users, :city, :string, :limit => 32, :after => :address2
    add_column :users, :state, :string, :limit => 2, :after => :city
    add_column :users, :zip, :string, :limit => 10, :after => :state
  end
end
