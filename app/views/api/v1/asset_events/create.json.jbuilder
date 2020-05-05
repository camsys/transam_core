json.asset_event do
  json.partial! 'api/v1/asset_events/asset_event', asset_event: @new_event
end