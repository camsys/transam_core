class FixDuplicateObjectKeys < ActiveRecord::DataMigration
  def up
    Rake::Task['transam_core_data:remove_dup_object_keys'].invoke('TransamAsset')
    Rake::Task['transam_core_data:remove_dup_object_keys'].invoke('AssetEvent')
  end
end