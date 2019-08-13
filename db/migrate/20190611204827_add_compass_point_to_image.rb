class AddCompassPointToImage < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :compass_point, :string
  end
end
