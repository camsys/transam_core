class RecentAssetEventsView < ApplicationRecord

  # Views don't have a discoverable PK so we need to manually set it to stop complaining
  self.primary_key = :asset_event_id

  # Force the model to be read-only
  include TransamReadOnlyModel

  belongs_to :transam_asset
  belongs_to :asset_event
  belongs_to :asset_event_type

end
