class FixPhoneNumberFields < ActiveRecord::Migration
  def change
    Organization.all.each do |o|
      old_phone = o.phone
      new_phone = old_phone.gsub(/[^0-9]/, "")
      o.update(phone: new_phone)
    end
    puts Organization.pluck(:phone)
    change_column :organizations, :phone, :string, :limit => 10, :null => false
    add_column    :organizations, :phone_ext, :string, :limit => 6, :default => nil, :after => :phone
  end
end
