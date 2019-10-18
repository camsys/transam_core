class RunKeywordSearchTransamAssets < ActiveRecord::DataMigration
  def up
    TransamAsset.all.each{|x| x.save!}
  end
end