class UpdateAssetManagerWeight < ActiveRecord::DataMigration
  def up
    Role.find_by(name: :asset_manager)&.update(weight: 8)
  end

  def down
    Role.find_by(name: :asset_manager)&.update(weight: nil)
  end
end