# Check that we got loaded from application.yml

#raise "Config not loaded from application.yml" unless ENV['ENV_FROM_APPLICATION_YML']


# General UI configuration settings
TransamAm::Application.config.ui_typeahead_delay = 300       # milliseconds delay between keystrokes before a query is sent to the server to retrieve a typeahead list
TransamAm::Application.config.ui_typeahead_min_chars = 1     # minimum number of characters to initiate a query
TransamAm::Application.config.ui_typeahead_list_length = 10  # max number of items displayed in the typeahead list  
TransamAm::Application.config.ui_search_items = 10           # max number of matching things to return in a search 
TransamAm::Application.config.ui_min_geocode_chars = 5       # Minimum number of characters (not including whitespace) before sending to the geocoder 

TransamAm::Application.config.map_bounds = [[40.48456,-74.36255], [40.943602,-73.701997]]
TransamAm::Application.config.geocoder_bounds = [[40.48456,-74.36255], [40.943602,-73.701997]]  
TransamAm::Application.config.geocoder_components = 'administrative_area:NY|country:US'

# Default params for spatial data
TransamAm::Application.config.default_srid = 3857
TransamAm::Application.config.default_search_radius = 300
TransamAm::Application.config.default_search_units = 'ft'


TransamAm::Application.config.object_cache_expire_seconds = 3600 # seconds to keep objects stored in the cache
TransamAm::Application.config.max_rows_returned = 500         # maximum number of rows to return from a database query

TransamAm::Application.config.asset_base_class_name = 'Sign'
