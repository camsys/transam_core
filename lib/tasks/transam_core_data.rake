# Mainly used for incremental seeding, or data change

namespace :transam_core_data do
  desc "Add event type for EarlyDispositionRequestUpdateEvent"
  task add_early_disposition_request_event_type: :environment do
    if AssetEventType && AssetEventType.where(class_name: 'EarlyDispositionRequestUpdateEvent').empty?
      config = {
        :active => 1, 
        :name => 'Request early disposition',     
        :display_icon_name => "fa fa-ban",      
        :description => 'Early Disposition Request',     
        :class_name => 'EarlyDispositionRequestUpdateEvent',   
        :job_name => ''
      }
      AssetEventType.new(config).save
    end
  end
end