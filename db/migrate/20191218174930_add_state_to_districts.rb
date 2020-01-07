class AddStateToDistricts < ActiveRecord::Migration[5.2]
  def change
    add_column :districts, :state, :string, after: :district_type_id
  end
end
