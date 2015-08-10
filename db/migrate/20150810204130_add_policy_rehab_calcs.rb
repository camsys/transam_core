class AddPolicyRehabCalcs < ActiveRecord::Migration
  def change
    add_column    :assets, :policy_rehabilitation_year, :integer, :after => :policy_replacement_year
    add_column    :assets, :last_rehabilitation_date, :date, :after => :disposition_type_id
  end
end
