if @asset
  json.(@asset, :object_key, :organization_id, :transam_assetible_type, :asset_subtype_id, :asset_tag, :description)
  json.asset_subtype @asset.asset_subtype.try(:to_s) 
  json.in_service_date @asset.in_service_date.try(:strftime, "%m/%d/%Y")
end

