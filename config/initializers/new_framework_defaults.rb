# transam has many belongs_to associations that are not required
# this is only necessary if the application loads defaults
# it also has to be set after load_defaults

Rails.application.config.active_record.belongs_to_required_by_default = false