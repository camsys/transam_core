class RunKeywordSearchTransamAssets < ActiveRecord::DataMigration
  def up
    if TransamAsset.respond_to? :not_in_transfer
      TransamAsset.not_in_transfer.each{|x| x.save!}
    else
      TransamAsset.all.each{|x| x.save!}
    end
  end
end