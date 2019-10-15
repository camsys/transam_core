class FixAssetsBadInServiceDate < ActiveRecord::DataMigration
  def up
    TransamAsset.where('in_service_date < purchase_date').each{|x| x.update!(in_service_date: x.purchase_date)}
  end
end