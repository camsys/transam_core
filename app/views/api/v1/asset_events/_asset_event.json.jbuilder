json.id(asset_event.object_key)
json.(asset_event, *asset_event.api_json.keys - [:id])