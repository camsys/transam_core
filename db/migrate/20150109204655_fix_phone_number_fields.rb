class FixPhoneNumberFields < ActiveRecord::Migration
  def change
    add_column    :organizations, :phone_ext, :string, :limit => 6, :after => :phone
    add_column    :users,         :phone_ext, :string, :limit => 6, :after => :phone
    add_column    :vendors,       :phone_ext, :string, :limit => 6, :after => :phone
  end
end
