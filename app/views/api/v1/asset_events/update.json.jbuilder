json.asset_event do
  json.partial! 'api/v1/asset_events/asset_event', asset_event: @typed_event
end