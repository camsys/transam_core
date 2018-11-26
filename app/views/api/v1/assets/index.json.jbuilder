if @assets
  json.assets @assets, :object_key, :transam_assetible_type, :organization_id, :asset_subtype_id, :asset_tag
end