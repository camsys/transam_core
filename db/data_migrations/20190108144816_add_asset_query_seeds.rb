class AddAssetQuerySeeds < ActiveRecord::DataMigration
  def up
    require TransamCore::Engine.root.join('db', 'seeds', 'asset_query_seeds.rb')
  end
end