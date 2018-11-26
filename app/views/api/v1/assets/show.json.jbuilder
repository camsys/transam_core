if @asset
  json.(@asset, :object_key, :organization_id, :asset_tag, :description)
  json.asset_type @asset.asset_type.try(:to_s) 
  json.asset_subtype @asset.asset_subtype.try(:to_s) 
  json.in_service_date @asset.in_service_date.try(:strftime, "%m/%d/%Y")
end

