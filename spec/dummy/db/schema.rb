# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141014210236) do

  create_table "activity_line_items", force: true do |t|
    t.string   "object_key",         limit: 12
    t.integer  "capital_project_id"
    t.integer  "team_ali_code_id"
    t.string   "name",               limit: 80
    t.integer  "anticipated_cost"
    t.integer  "estimated_cost"
    t.text     "cost_justification"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activity_line_items", ["capital_project_id", "object_key"], name: "activity_line_items_idx1"
  add_index "activity_line_items", ["capital_project_id"], name: "activity_line_items_idx2"

  create_table "activity_line_items_assets", force: true do |t|
    t.integer "activity_line_item_id"
    t.integer "asset_id"
  end

  add_index "activity_line_items_assets", ["activity_line_item_id", "asset_id"], name: "activity_line_items_assets_idx1"

  create_table "activity_logs", force: true do |t|
    t.integer  "organization_id",                                            null: false
    t.string   "item_type",       limit: 64, default: "Object",              null: false
    t.integer  "item_id"
    t.integer  "user_id",                                                    null: false
    t.text     "activity",                                                   null: false
    t.datetime "activity_time",              default: '2014-05-05 10:38:27'
  end

  add_index "activity_logs", ["organization_id", "activity_time"], name: "activity_logs_idx1"
  add_index "activity_logs", ["user_id", "activity_time"], name: "activity_logs_idx2"

  create_table "asset_event_types", force: true do |t|
    t.string  "name",              limit: 64,  null: false
    t.string  "class_name",        limit: 64,  null: false
    t.string  "job_name",          limit: 64,  null: false
    t.string  "display_icon_name", limit: 64,  null: false
    t.string  "description",       limit: 254, null: false
    t.boolean "active",                        null: false
  end

  add_index "asset_event_types", ["class_name"], name: "asset_event_types_idx1"

  create_table "asset_events", force: true do |t|
    t.string   "object_key",                     limit: 12,                          null: false
    t.integer  "asset_id",                                                           null: false
    t.integer  "asset_event_type_id",                                                null: false
    t.date     "event_date",                                                         null: false
    t.decimal  "assessed_rating",                            precision: 9, scale: 2
    t.integer  "condition_type_id"
    t.integer  "current_mileage"
    t.integer  "location_id"
    t.integer  "replacement_year"
    t.integer  "rebuild_year"
    t.integer  "disposition_year"
    t.integer  "replacement_reason_type_id"
    t.date     "disposition_date"
    t.integer  "disposition_type_id"
    t.integer  "service_status_type_id"
    t.integer  "pcnt_5311_routes"
    t.integer  "avg_daily_use"
    t.integer  "avg_daily_passenger_trips"
    t.integer  "maintenance_provider_type_id"
    t.integer  "vehicle_storage_method_type_id"
    t.decimal  "avg_cost_per_mile",                          precision: 9, scale: 2
    t.decimal  "avg_miles_per_gallon",                       precision: 9, scale: 2
    t.integer  "annual_maintenance_cost"
    t.integer  "annual_insurance_cost"
    t.boolean  "actual_costs"
    t.integer  "sales_proceeds"
    t.string   "new_owner_name",                 limit: 64
    t.string   "address1",                       limit: 128
    t.string   "address2",                       limit: 128
    t.string   "city",                           limit: 64
    t.string   "state",                          limit: 2
    t.string   "zip",                            limit: 10
    t.text     "comments"
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
  end

  add_index "asset_events", ["asset_event_type_id"], name: "asset_events_idx3"
  add_index "asset_events", ["asset_id"], name: "asset_events_idx2"
  add_index "asset_events", ["event_date"], name: "asset_events_idx4"
  add_index "asset_events", ["object_key"], name: "asset_events_idx1"

  create_table "asset_events_vehicle_usage_codes", id: false, force: true do |t|
    t.integer "asset_event_id"
    t.integer "vehicle_usage_code_id"
  end

  add_index "asset_events_vehicle_usage_codes", ["asset_event_id", "vehicle_usage_code_id"], name: "asset_events_vehicle_usage_codes_idx1"

  create_table "asset_groups", force: true do |t|
    t.string   "object_key",      limit: 12
    t.integer  "organization_id"
    t.string   "name",            limit: 64
    t.string   "code",            limit: 8
    t.text     "description"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "asset_groups", ["object_key"], name: "asset_groups_idx1", unique: true
  add_index "asset_groups", ["organization_id"], name: "asset_groups_idx2"

  create_table "asset_groups_assets", id: false, force: true do |t|
    t.integer "asset_id",       null: false
    t.integer "asset_group_id", null: false
  end

  create_table "asset_subtypes", force: true do |t|
    t.integer "asset_type_id",                            null: false
    t.string  "name",          limit: 64,                 null: false
    t.string  "ali_code",      limit: 2
    t.string  "description",   limit: 254,                null: false
    t.string  "image",         limit: 254
    t.boolean "active",                    default: true, null: false
  end

  add_index "asset_subtypes", ["asset_type_id"], name: "asset_subtypes_idx1"

  create_table "asset_types", force: true do |t|
    t.string  "name",                             limit: 64,  null: false
    t.string  "class_name",                       limit: 64,  null: false
    t.string  "display_icon_name",                limit: 64,  null: false
    t.string  "map_icon_name",                    limit: 64,  null: false
    t.string  "description",                      limit: 254, null: false
    t.boolean "active",                                       null: false
    t.string  "new_inventory_template_name"
    t.string  "status_update_template_name"
    t.string  "disposition_update_template_name"
  end

  add_index "asset_types", ["class_name"], name: "asset_types_idx1"

  create_table "asset_types_manufacturers", id: false, force: true do |t|
    t.integer "asset_type_id"
    t.integer "manufacturer_id"
  end

  add_index "asset_types_manufacturers", ["asset_type_id", "manufacturer_id"], name: "asset_types_manufacturersidx1"

  create_table "assets", force: true do |t|
    t.string   "object_key",                         limit: 12,                           null: false
    t.integer  "organization_id",                                                         null: false
    t.integer  "asset_type_id",                                                           null: false
    t.integer  "asset_subtype_id",                                                        null: false
    t.string   "asset_tag",                          limit: 32,                           null: false
    t.integer  "location_id"
    t.integer  "manufacturer_id"
    t.string   "manufacturer_model",                 limit: 128
    t.integer  "manufacture_year"
    t.integer  "policy_replacement_year"
    t.integer  "estimated_replacement_year"
    t.integer  "estimated_replacement_cost"
    t.integer  "scheduled_replacement_year"
    t.integer  "scheduled_rehabilitation_year"
    t.integer  "scheduled_disposition_year"
    t.boolean  "scheduled_by_user"
    t.integer  "replacement_reason_type_id"
    t.boolean  "in_backlog"
    t.integer  "reported_condition_type_id"
    t.decimal  "reported_condition_rating",                      precision: 10, scale: 1
    t.integer  "reported_mileage"
    t.date     "reported_condition_date"
    t.integer  "estimated_condition_type_id"
    t.decimal  "estimated_condition_rating",                     precision: 9,  scale: 2
    t.integer  "service_status_type_id"
    t.date     "service_status_date"
    t.integer  "estimated_value"
    t.date     "disposition_date"
    t.integer  "disposition_type_id"
    t.integer  "maintenance_provider_type_id"
    t.integer  "vehicle_storage_method_type_id"
    t.integer  "location_reference_type_id"
    t.string   "location_reference",                 limit: 254
    t.text     "location_comments"
    t.integer  "fuel_type_id"
    t.integer  "vehicle_length"
    t.string   "title_number",                       limit: 32
    t.integer  "title_owner_organization_id"
    t.string   "vin",                                limit: 32
    t.boolean  "purchased_new"
    t.integer  "purchase_cost"
    t.date     "purchase_date"
    t.date     "in_service_date"
    t.integer  "expected_useful_life"
    t.integer  "expected_useful_miles"
    t.integer  "purchase_method_type_id"
    t.integer  "rebuild_year"
    t.string   "license_plate",                      limit: 32
    t.integer  "seating_capacity"
    t.integer  "standing_capacity"
    t.integer  "wheelchair_capacity"
    t.integer  "fta_ownership_type_id"
    t.integer  "fta_vehicle_type_id"
    t.integer  "fta_funding_type_id"
    t.integer  "fta_funding_source_type_id"
    t.integer  "pcnt_federal_funding"
    t.boolean  "ada_accessible_lift"
    t.boolean  "ada_accessible_ramp"
    t.boolean  "fta_emergency_contingency_fleet"
    t.string   "description",                        limit: 128
    t.string   "address1",                           limit: 128
    t.string   "address2",                           limit: 128
    t.string   "city",                               limit: 64
    t.string   "state",                              limit: 2
    t.string   "zip",                                limit: 10
    t.integer  "facility_size"
    t.integer  "pcnt_operational"
    t.integer  "num_floors"
    t.integer  "num_structures"
    t.integer  "num_elevators"
    t.integer  "num_escalators"
    t.decimal  "lot_size",                                       precision: 9,  scale: 2
    t.integer  "land_ownership_type_id"
    t.integer  "land_ownership_organization_id"
    t.integer  "building_ownership_type_id"
    t.integer  "building_ownership_organization_id"
    t.integer  "facility_capacity_type_id"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.integer  "scheduled_replacement_cost"
    t.boolean  "scheduled_replace_with_new"
    t.integer  "scheduled_rehabilitation_cost"
  end

  add_index "assets", ["asset_subtype_id"], name: "assets_idx4"
  add_index "assets", ["asset_type_id"], name: "assets_idx3"
  add_index "assets", ["estimated_replacement_year"], name: "assets_idx8"
  add_index "assets", ["in_backlog"], name: "assets_idx7"
  add_index "assets", ["manufacture_year"], name: "assets_idx5"
  add_index "assets", ["object_key"], name: "assets_idx1"
  add_index "assets", ["organization_id", "asset_subtype_id", "in_backlog"], name: "assets_idx12"
  add_index "assets", ["organization_id", "asset_subtype_id", "policy_replacement_year"], name: "assets_idx10"
  add_index "assets", ["organization_id", "in_backlog"], name: "assets_idx11"
  add_index "assets", ["organization_id", "policy_replacement_year"], name: "assets_idx9"
  add_index "assets", ["organization_id"], name: "assets_idx2"
  add_index "assets", ["reported_condition_type_id"], name: "assets_idx6"

  create_table "assets_districts", id: false, force: true do |t|
    t.integer "asset_id"
    t.integer "district_id"
  end

  add_index "assets_districts", ["asset_id", "district_id"], name: "assets_districts_idx1"

  create_table "assets_facility_features", id: false, force: true do |t|
    t.integer "asset_id",            null: false
    t.integer "facility_feature_id", null: false
  end

  create_table "assets_fta_mode_types", id: false, force: true do |t|
    t.integer "asset_id"
    t.integer "fta_mode_type_id"
  end

  add_index "assets_fta_mode_types", ["asset_id", "fta_mode_type_id"], name: "assets_fta_mode_types_idx1"

  create_table "assets_fta_service_types", id: false, force: true do |t|
    t.integer "asset_id"
    t.integer "fta_service_type_id"
  end

  add_index "assets_fta_service_types", ["asset_id", "fta_service_type_id"], name: "assets_fta_service_types_idx1"

  create_table "assets_usage_codes", id: false, force: true do |t|
    t.integer "asset_id"
    t.integer "usage_code_id"
  end

  add_index "assets_usage_codes", ["asset_id", "usage_code_id"], name: "assets_usage_codes_idx1"

  create_table "assets_vehicle_features", id: false, force: true do |t|
    t.integer "asset_id"
    t.integer "vehicle_feature_id"
  end

  add_index "assets_vehicle_features", ["asset_id", "vehicle_feature_id"], name: "assets_vehicle_features_idx1"

  create_table "assets_vehicle_usage_codes", id: false, force: true do |t|
    t.integer "asset_id",              null: false
    t.integer "vehicle_usage_code_id", null: false
  end

  add_index "assets_vehicle_usage_codes", ["asset_id", "vehicle_usage_code_id"], name: "assets_vehicle_usage_codes_idx1"

  create_table "attachment_types", force: true do |t|
    t.string  "name",              limit: 64,                 null: false
    t.string  "description",       limit: 254,                null: false
    t.string  "display_icon_name", limit: 64,                 null: false
    t.boolean "active",                        default: true, null: false
  end

  create_table "attachments", force: true do |t|
    t.string   "object_key",         limit: 12,  null: false
    t.integer  "asset_id",                       null: false
    t.integer  "attachment_type_id",             null: false
    t.string   "name",               limit: 64,  null: false
    t.string   "image",              limit: 128
    t.string   "document",           limit: 128
    t.text     "notes"
    t.string   "original_filename",  limit: 254, null: false
    t.string   "content_type",       limit: 128
    t.integer  "file_size"
    t.integer  "created_by_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "attachments", ["asset_id"], name: "attachments_idx2"
  add_index "attachments", ["attachment_type_id"], name: "attachments_idx3"
  add_index "attachments", ["object_key"], name: "attachments_idx1"

  create_table "capital_project_status_types", force: true do |t|
    t.string  "name",        limit: 64
    t.string  "description"
    t.boolean "active"
  end

  create_table "capital_project_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 4,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "capital_projects", force: true do |t|
    t.string   "object_key",                     limit: 12
    t.integer  "fy_year"
    t.string   "project_number",                 limit: 32
    t.integer  "organization_id"
    t.integer  "team_ali_code_id"
    t.integer  "capital_project_type_id"
    t.integer  "capital_project_status_type_id"
    t.string   "title",                          limit: 80
    t.text     "description"
    t.text     "justification"
    t.boolean  "emergency"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "capital_projects", ["organization_id", "capital_project_type_id"], name: "capital_projects_idx4"
  add_index "capital_projects", ["organization_id", "fy_year"], name: "capital_projects_idx3"
  add_index "capital_projects", ["organization_id", "object_key"], name: "capital_projects_idx1"
  add_index "capital_projects", ["organization_id", "project_number"], name: "capital_projects_idx2"

  create_table "capital_projects_mpms_projects", force: true do |t|
    t.integer "capital_project_id"
    t.integer "mpms_project_id"
  end

  add_index "capital_projects_mpms_projects", ["capital_project_id", "mpms_project_id"], name: "capital_projects_mpms_projects_idx1"

  create_table "comments", force: true do |t|
    t.string   "object_key",       limit: 12
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "comment"
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "comments_idx1"

  create_table "condition_estimation_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "class_name",  limit: 64,                 null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  add_index "condition_estimation_types", ["class_name"], name: "condition_estimation_types_idx1"

  create_table "condition_types", force: true do |t|
    t.string  "name",        limit: 64,                                         null: false
    t.decimal "rating",                  precision: 9, scale: 2,                null: false
    t.string  "description", limit: 254,                                        null: false
    t.boolean "active",                                          default: true, null: false
  end

  create_table "cost_calculation_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "class_name",  limit: 64,                 null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  add_index "cost_calculation_types", ["class_name"], name: "cost_calculation_types_idx1"

  create_table "customers", force: true do |t|
    t.integer  "license_type_id",            null: false
    t.string   "name",            limit: 64, null: false
    t.boolean  "active",                     null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "depreciation_calculation_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "class_name",  limit: 64,                 null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "disposition_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "code",        limit: 2,                  null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "district_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "districts", force: true do |t|
    t.integer "district_type_id",                            null: false
    t.string  "name",             limit: 64,                 null: false
    t.string  "code",             limit: 6,                  null: false
    t.string  "description",      limit: 254,                null: false
    t.boolean "active",                       default: true, null: false
  end

  add_index "districts", ["district_type_id"], name: "districts_idx1"
  add_index "districts", ["name"], name: "districts_idx2"

  create_table "documents", force: true do |t|
    t.string   "object_key",        limit: 12
    t.integer  "documentable_id"
    t.string   "documentable_type"
    t.string   "document",          limit: 128
    t.string   "description"
    t.string   "original_filename", limit: 128
    t.string   "content_type",      limit: 128
    t.integer  "file_size"
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "documents", ["documentable_id", "documentable_type"], name: "documents_idx2"
  add_index "documents", ["object_key"], name: "documents_idx1"

  create_table "facility_capacity_types", force: true do |t|
    t.string  "name",        limit: 64
    t.string  "description", limit: 254
    t.boolean "active"
  end

  create_table "facility_features", force: true do |t|
    t.string  "name",        limit: 64
    t.string  "code",        limit: 3
    t.string  "description", limit: 254
    t.boolean "active"
  end

  create_table "file_content_types", force: true do |t|
    t.string  "name",         limit: 64,  null: false
    t.string  "class_name",   limit: 64,  null: false
    t.string  "builder_name"
    t.string  "description",  limit: 254, null: false
    t.boolean "active",                   null: false
  end

  add_index "file_content_types", ["class_name"], name: "file_content_types_idx2"
  add_index "file_content_types", ["name"], name: "file_content_types_idx1"

  create_table "file_status_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  add_index "file_status_types", ["name"], name: "file_status_types_idx1"

  create_table "fta_agency_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "description", limit: 256,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "fta_funding_source_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "description", limit: 256,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "fta_funding_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "code",        limit: 4,                  null: false
    t.string  "description", limit: 256,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "fta_mode_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 2,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_ownership_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 4,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_service_area_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_service_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 2,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_vehicle_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 2,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fuel_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "code",        limit: 2,                  null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "funding_amounts", force: true do |t|
    t.string   "object_key",        limit: 12
    t.integer  "fy_year"
    t.integer  "funding_source_id"
    t.integer  "amount"
    t.boolean  "estimated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "funding_amounts", ["funding_source_id", "fy_year"], name: "funding_amounts_idx2"
  add_index "funding_amounts", ["object_key"], name: "funding_amounts_idx1"

  create_table "funding_line_item_types", force: true do |t|
    t.string  "code",        limit: 2
    t.string  "name",        limit: 64
    t.string  "description"
    t.boolean "active"
  end

  create_table "funding_line_items", force: true do |t|
    t.string   "object_key",                limit: 12
    t.integer  "organization_id"
    t.integer  "fy_year"
    t.integer  "funding_source_id"
    t.integer  "funding_line_item_type_id"
    t.string   "project_number",            limit: 64
    t.boolean  "awarded"
    t.integer  "amount"
    t.integer  "spent"
    t.integer  "pcnt_operating_assistance"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "funding_line_items", ["object_key"], name: "funding_line_items_idx1"
  add_index "funding_line_items", ["organization_id", "object_key"], name: "funding_line_items_idx2"
  add_index "funding_line_items", ["project_number"], name: "funding_line_items_idx3"

  create_table "funding_requests", force: true do |t|
    t.string   "object_key",                   limit: 12
    t.integer  "activity_line_item_id"
    t.integer  "federal_funding_line_item_id"
    t.integer  "state_funding_line_item_id"
    t.integer  "federal_amount"
    t.integer  "state_amount"
    t.integer  "local_amount"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "funding_requests", ["activity_line_item_id", "federal_funding_line_item_id"], name: "available_funds_idx2"
  add_index "funding_requests", ["object_key"], name: "funding_requests_idx1"

  create_table "funding_source_types", force: true do |t|
    t.string  "name",        limit: 64
    t.string  "description"
    t.boolean "active"
  end

  create_table "funding_sources", force: true do |t|
    t.string   "object_key",                      limit: 12
    t.string   "name",                            limit: 64
    t.text     "description"
    t.integer  "funding_source_type_id"
    t.string   "external_id",                     limit: 32
    t.boolean  "state_administered_federal_fund"
    t.boolean  "bond_fund"
    t.boolean  "formula_fund"
    t.boolean  "non_committed_fund"
    t.boolean  "contracted_fund"
    t.boolean  "discretionary_fund"
    t.float    "state_match_required",            limit: 24
    t.float    "federal_match_required",          limit: 24
    t.float    "local_match_required",            limit: 24
    t.boolean  "rural_providers"
    t.boolean  "urban_providers"
    t.boolean  "shared_ride_providers"
    t.boolean  "inter_city_bus_providers"
    t.boolean  "inter_city_rail_providers"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "funding_sources", ["object_key"], name: "funding_sources_idx1"

  create_table "images", force: true do |t|
    t.string   "object_key",        limit: 12
    t.integer  "imagable_id"
    t.string   "imagable_type"
    t.string   "image",             limit: 128
    t.string   "description"
    t.string   "original_filename", limit: 128
    t.string   "content_type",      limit: 128
    t.integer  "file_size"
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["imagable_id", "imagable_type"], name: "images_idx2"
  add_index "images", ["object_key"], name: "images_idx1"

  create_table "issue_types", force: true do |t|
    t.string  "name",        limit: 64
    t.string  "description"
    t.boolean "active"
  end

  create_table "issues", force: true do |t|
    t.string   "object_key",          limit: 12
    t.integer  "issue_type_id"
    t.integer  "web_browser_type_id"
    t.integer  "created_by_id"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issues", ["issue_type_id"], name: "issues_idx2"
  add_index "issues", ["object_key"], name: "issues_idx1"

  create_table "license_types", force: true do |t|
    t.string  "name",          limit: 64,  null: false
    t.string  "description",   limit: 254, null: false
    t.boolean "asset_manager",             null: false
    t.boolean "web_services",              null: false
    t.boolean "active",                    null: false
  end

  create_table "location_reference_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "format",      limit: 64,                 null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "maintenance_provider_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 2,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "manufacturers", force: true do |t|
    t.string  "filter", limit: 32,                 null: false
    t.string  "name",   limit: 128,                null: false
    t.string  "code",   limit: 3,                  null: false
    t.boolean "active",             default: true, null: false
  end

  add_index "manufacturers", ["filter"], name: "manufacturers_idx1"

  create_table "messages", force: true do |t|
    t.string   "object_key",        limit: 12, null: false
    t.integer  "organization_id",              null: false
    t.integer  "user_id",                      null: false
    t.integer  "to_user_id"
    t.integer  "priority_type_id",             null: false
    t.integer  "thread_message_id"
    t.string   "subject",           limit: 64, null: false
    t.text     "body"
    t.datetime "opened_at"
    t.datetime "created_at",                   null: false
  end

  add_index "messages", ["object_key"], name: "messages_idx1"
  add_index "messages", ["organization_id"], name: "messages_idx2"
  add_index "messages", ["thread_message_id"], name: "messages_idx5"
  add_index "messages", ["to_user_id"], name: "messages_idx4"
  add_index "messages", ["user_id"], name: "messages_idx3"

  create_table "milestone_types", force: true do |t|
    t.string  "name",                limit: 64
    t.string  "description"
    t.boolean "is_vehicle_delivery"
    t.boolean "active"
  end

  create_table "milestones", force: true do |t|
    t.string   "object_key",            limit: 12
    t.integer  "activity_line_item_id"
    t.integer  "milestone_type_id"
    t.date     "milestone_date"
    t.string   "comments"
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "milestones", ["activity_line_item_id", "milestone_date"], name: "milestones_idx2"
  add_index "milestones", ["activity_line_item_id", "object_key"], name: "milestones_idx1"

  create_table "mpms_projects", force: true do |t|
    t.integer "capital_project_id"
    t.string  "external_id",        limit: 32
    t.string  "name",               limit: 64
    t.string  "description"
    t.boolean "active"
  end

  add_index "mpms_projects", ["capital_project_id"], name: "mpms_projects_idx1"

  create_table "notes", force: true do |t|
    t.string   "object_key",    limit: 12, null: false
    t.integer  "asset_id",                 null: false
    t.text     "comments"
    t.integer  "created_by_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "notes", ["asset_id"], name: "notes_idx2"
  add_index "notes", ["object_key"], name: "notes_idx1"

  create_table "notice_types", force: true do |t|
    t.string  "name",          limit: 64
    t.string  "description",   limit: 254
    t.string  "display_icon",  limit: 64
    t.string  "display_class", limit: 64
    t.boolean "active"
  end

  create_table "notices", force: true do |t|
    t.string   "object_key",           limit: 12
    t.integer  "organization_type_id"
    t.string   "subject",              limit: 64
    t.string   "summary",              limit: 128
    t.text     "details"
    t.integer  "notice_type_id"
    t.datetime "display_datetime"
    t.datetime "end_datetime"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_types", force: true do |t|
    t.string  "name",              limit: 64,  null: false
    t.string  "class_name",        limit: 64,  null: false
    t.string  "display_icon_name", limit: 64,  null: false
    t.string  "map_icon_name",     limit: 64,  null: false
    t.string  "description",       limit: 254, null: false
    t.boolean "active",                        null: false
  end

  add_index "organization_types", ["class_name"], name: "organization_types_idx1"

  create_table "organizations", force: true do |t|
    t.integer  "organization_type_id",                                          null: false
    t.integer  "customer_id",                                                   null: false
    t.string   "external_id",              limit: 32
    t.string   "name",                     limit: 128,                          null: false
    t.string   "short_name",               limit: 16,                           null: false
    t.boolean  "license_holder",                                                null: false
    t.string   "address1",                 limit: 128,                          null: false
    t.string   "address2",                 limit: 128
    t.string   "county",                   limit: 64
    t.string   "city",                     limit: 64,                           null: false
    t.string   "state",                    limit: 2,                            null: false
    t.string   "zip",                      limit: 10,                           null: false
    t.string   "phone",                    limit: 12,                           null: false
    t.string   "fax",                      limit: 10
    t.string   "url",                      limit: 128,                          null: false
    t.integer  "grantor_id"
    t.integer  "fta_agency_type_id"
    t.boolean  "indian_tribe"
    t.integer  "urban_rural_type_id"
    t.string   "subrecipient_number",      limit: 9
    t.string   "team_number",              limit: 4
    t.integer  "fta_service_area_type_id"
    t.boolean  "active",                                                        null: false
    t.decimal  "latitude",                             precision: 11, scale: 6
    t.decimal  "longitude",                            precision: 11, scale: 6
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
  end

  add_index "organizations", ["customer_id"], name: "organizations_idx2"
  add_index "organizations", ["grantor_id"], name: "organizations_idx3"
  add_index "organizations", ["organization_type_id"], name: "organizations_idx1"
  add_index "organizations", ["short_name"], name: "organizations_idx4"
  add_index "organizations", ["short_name"], name: "short_name", unique: true
  add_index "organizations", ["urban_rural_type_id"], name: "orgnizations_idx5"

  create_table "organizations_districts", id: false, force: true do |t|
    t.integer "organization_id"
    t.integer "district_id"
  end

  add_index "organizations_districts", ["organization_id", "district_id"], name: "organizations_districts_idx2"

  create_table "organizations_service_types", id: false, force: true do |t|
    t.integer "organization_id"
    t.integer "service_type_id"
  end

  add_index "organizations_service_types", ["organization_id", "service_type_id"], name: "organizations_service_types_idx1"

  create_table "policies", force: true do |t|
    t.string   "object_key",                       limit: 12,                                        null: false
    t.integer  "organization_id",                                                                    null: false
    t.integer  "year",                                                                               null: false
    t.string   "name",                             limit: 64,                                        null: false
    t.text     "description",                                                                        null: false
    t.integer  "depreciation_calculation_type_id",                                                   null: false
    t.integer  "service_life_calculation_type_id",                                                   null: false
    t.integer  "cost_calculation_type_id",                                                           null: false
    t.integer  "condition_estimation_type_id",                                                       null: false
    t.decimal  "condition_threshold",                         precision: 9, scale: 2,                null: false
    t.decimal  "interest_rate",                               precision: 9, scale: 2,                null: false
    t.boolean  "current",                                                             default: true, null: false
    t.boolean  "active",                                                              default: true, null: false
    t.datetime "created_at",                                                                         null: false
    t.datetime "updated_at",                                                                         null: false
    t.integer  "parent_id"
  end

  add_index "policies", ["object_key"], name: "policies_idx1"
  add_index "policies", ["organization_id"], name: "policies_idx2"

  create_table "policy_items", force: true do |t|
    t.integer  "policy_id",                                            null: false
    t.integer  "asset_subtype_id",                                     null: false
    t.integer  "max_service_life_years",                               null: false
    t.integer  "max_service_life_miles"
    t.integer  "replacement_cost",                                     null: false
    t.integer  "rehabilitation_cost"
    t.integer  "extended_service_life_years"
    t.integer  "extended_service_life_miles"
    t.integer  "pcnt_residual_value",                                  null: false
    t.boolean  "active",                                default: true, null: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "fuel_type_id"
    t.string   "replacement_ali_code",        limit: 8
    t.integer  "replace_asset_subtype_id"
    t.integer  "replace_fuel_type_id"
    t.string   "rehabilitation_ali_code",     limit: 8
    t.integer  "rehabilitation_year"
  end

  add_index "policy_items", ["asset_subtype_id"], name: "policy_items_idx2"
  add_index "policy_items", ["policy_id"], name: "policy_items_idx1"

  create_table "priority_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "is_default",              null: false
    t.boolean "active",                  null: false
  end

  create_table "purchase_method_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 2,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username",   limit: 64
    t.integer  "item"
    t.string   "table",      limit: 64
    t.integer  "month"
    t.integer  "year"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories"

  create_table "replacement_reason_types", force: true do |t|
    t.string  "name",        limit: 64
    t.string  "description"
    t.boolean "active"
  end

  create_table "report_types", force: true do |t|
    t.string  "name",              limit: 64,  null: false
    t.string  "description",       limit: 254, null: false
    t.string  "display_icon_name", limit: 64,  null: false
    t.boolean "active",                        null: false
  end

  create_table "reports", force: true do |t|
    t.integer  "report_type_id",                null: false
    t.string   "name",              limit: 64,  null: false
    t.string   "description",       limit: 254, null: false
    t.string   "class_name",        limit: 32,  null: false
    t.string   "view_name",         limit: 32,  null: false
    t.string   "roles",             limit: 128
    t.text     "custom_sql"
    t.boolean  "show_in_nav"
    t.boolean  "show_in_dashboard"
    t.string   "chart_type",        limit: 32
    t.text     "chart_options"
    t.boolean  "active",                        null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "reports", ["report_type_id"], name: "reports_idx1"

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "roles", ["name"], name: "roles_idx1"
  add_index "roles", ["resource_id"], name: "roles_idx2"

  create_table "service_life_calculation_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "class_name",  limit: 64,                 null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  add_index "service_life_calculation_types", ["class_name"], name: "service_life_calculation_types_idx1"

  create_table "service_provider_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "code",        limit: 5,                  null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "service_status_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "code",        limit: 1,                  null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "service_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "code",        limit: 5,                  null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "system_configs", force: true do |t|
    t.integer  "customer_id"
    t.string   "start_of_fiscal_year",  limit: 5
    t.string   "map_tile_provider",     limit: 64
    t.integer  "srid"
    t.float    "min_lat",               limit: 24
    t.float    "min_lon",               limit: 24
    t.float    "max_lat",               limit: 24
    t.float    "max_lon",               limit: 24
    t.integer  "search_radius"
    t.string   "search_units",          limit: 8
    t.string   "geocoder_components",   limit: 128
    t.string   "geocoder_region",       limit: 64
    t.integer  "num_forecasting_years"
    t.integer  "num_reporting_years"
    t.string   "asset_base_class_name", limit: 64
    t.integer  "max_rows_returned"
    t.string   "data_file_path",        limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_status_types", force: true do |t|
    t.string  "name",        limit: 64
    t.string  "description", limit: 254
    t.boolean "active"
  end

  create_table "tasks", force: true do |t|
    t.string   "object_key",           limit: 12, null: false
    t.integer  "from_user_id",                    null: false
    t.integer  "from_organization_id",            null: false
    t.integer  "priority_type_id",                null: false
    t.integer  "for_organization_id",             null: false
    t.integer  "assigned_to_user_id"
    t.string   "subject",              limit: 64, null: false
    t.text     "body",                            null: false
    t.boolean  "send_reminder"
    t.integer  "task_status_type_id"
    t.datetime "complete_by",                     null: false
    t.datetime "completed_on"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "tasks", ["assigned_to_user_id"], name: "tasks_idx5"
  add_index "tasks", ["complete_by"], name: "tasks_idx6"
  add_index "tasks", ["for_organization_id"], name: "tasks_idx4"
  add_index "tasks", ["from_organization_id"], name: "tasks_idx3"
  add_index "tasks", ["from_user_id"], name: "tasks_idx2"
  add_index "tasks", ["object_key"], name: "tasks_idx1"

  create_table "team_ali_codes", force: true do |t|
    t.string  "name",      limit: 64
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.string  "code",      limit: 8
    t.boolean "active"
  end

  add_index "team_ali_codes", ["code"], name: "team_scope_ali_codes_idx3"
  add_index "team_ali_codes", ["name"], name: "team_scope_ali_codes_idx1"
  add_index "team_ali_codes", ["rgt"], name: "team_scope_ali_codes_idx2"

  create_table "uploads", force: true do |t|
    t.string   "object_key",              limit: 12,         null: false
    t.integer  "organization_id",                            null: false
    t.integer  "user_id",                                    null: false
    t.integer  "file_content_type_id",                       null: false
    t.integer  "file_status_type_id",                        null: false
    t.string   "file",                    limit: 128,        null: false
    t.string   "original_filename",       limit: 254,        null: false
    t.integer  "num_rows_processed"
    t.integer  "num_rows_added"
    t.integer  "num_rows_replaced"
    t.integer  "num_rows_skipped"
    t.integer  "num_rows_failed"
    t.text     "processing_log",          limit: 2147483647
    t.boolean  "force_update"
    t.datetime "processing_started_at"
    t.datetime "processing_completed_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "uploads", ["file_content_type_id"], name: "uploads_idx4"
  add_index "uploads", ["file_status_type_id"], name: "uploads_idx5"
  add_index "uploads", ["object_key"], name: "uploads_idx1"
  add_index "uploads", ["organization_id"], name: "uploads_idx2"
  add_index "uploads", ["user_id"], name: "uploads_idx3"

  create_table "user_organization_filters", force: true do |t|
    t.string   "object_key",  limit: 12
    t.integer  "user_id"
    t.string   "name",        limit: 64
    t.string   "description", limit: 254
    t.text     "form_params"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_organization_filters", ["object_key"], name: "user_organization_filters_idx1"
  add_index "user_organization_filters", ["user_id"], name: "user_organization_filters_idx2"

  create_table "user_organization_filters_organizations", id: false, force: true do |t|
    t.integer "user_organization_filter_id", null: false
    t.integer "organization_id",             null: false
  end

  add_index "user_organization_filters_organizations", ["user_organization_filter_id", "organization_id"], name: "user_organization_filters_idx3"

  create_table "users", force: true do |t|
    t.string   "object_key",                  limit: 12,                  null: false
    t.integer  "organization_id",                                         null: false
    t.string   "external_id",                 limit: 32
    t.string   "first_name",                  limit: 64,                  null: false
    t.string   "last_name",                   limit: 64,                  null: false
    t.string   "title",                       limit: 64
    t.string   "phone",                       limit: 12,                  null: false
    t.string   "timezone",                    limit: 32,                  null: false
    t.string   "email",                       limit: 128,                 null: false
    t.integer  "num_table_rows",                          default: 10
    t.integer  "user_organization_filter_id",             default: 1
    t.string   "encrypted_password",          limit: 64,                  null: false
    t.string   "reset_password_token",        limit: 64
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                           default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",          limit: 16
    t.string   "last_sign_in_ip",             limit: 16
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "failed_attempts",                         default: 0,     null: false
    t.string   "unlock_token",                limit: 128
    t.datetime "locked_at"
    t.boolean  "notify_via_email",                        default: false, null: false
    t.boolean  "active",                                  default: false, null: false
  end

  add_index "users", ["email"], name: "users_idx3"
  add_index "users", ["object_key"], name: "users_idx1"
  add_index "users", ["organization_id"], name: "users_idx2"

  create_table "users_organizations", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "organization_id"
  end

  add_index "users_organizations", ["user_id", "organization_id"], name: "users_organizations_idx2"

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "users_roles_idx2"

  create_table "vehicle_features", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "code",        limit: 3,                  null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "vehicle_storage_method_types", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "code",        limit: 1,                  null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "vehicle_usage_codes", force: true do |t|
    t.string  "name",        limit: 64,                 null: false
    t.string  "code",        limit: 1,                  null: false
    t.string  "description", limit: 254,                null: false
    t.boolean "active",                  default: true, null: false
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  create_table "web_browser_types", force: true do |t|
    t.string  "name",        limit: 64
    t.string  "description"
    t.boolean "active"
  end

end
