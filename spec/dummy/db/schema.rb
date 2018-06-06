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

ActiveRecord::Schema.define(version: 20180327175416) do

  create_table "activities", force: :cascade do |t|
    t.string   "object_key",           limit: 12
    t.integer  "organization_type_id", limit: 4
    t.string   "name",                 limit: 64
    t.text     "description",          limit: 65535
    t.boolean  "show_in_dashboard"
    t.boolean  "system_activity"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "frequency_quantity",   limit: 4,     null: false
    t.integer  "frequency_type_id",    limit: 4,     null: false
    t.string   "execution_time",       limit: 32,    null: false
    t.string   "job_name",             limit: 64
    t.datetime "last_run"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activity_logs", force: :cascade do |t|
    t.integer  "organization_id", limit: 4,          null: false
    t.string   "item_type",       limit: 64,         null: false
    t.integer  "item_id",         limit: 4
    t.integer  "user_id",         limit: 4,          null: false
    t.text     "activity",        limit: 4294967295, null: false
    t.datetime "activity_time"
  end

  add_index "activity_logs", ["organization_id", "activity_time"], name: "activity_logs_idx1", using: :btree
  add_index "activity_logs", ["user_id", "activity_time"], name: "activity_logs_idx2", using: :btree

  create_table "archived_fiscal_years", id: false, force: :cascade do |t|
    t.integer "organization_id", limit: 4
    t.integer "fy_year",         limit: 4
  end

  add_index "archived_fiscal_years", ["organization_id"], name: "index_archived_fiscal_years_on_organization_id", using: :btree

  create_table "asset_event_asset_subsystems", force: :cascade do |t|
    t.integer "asset_event_id",     limit: 4
    t.integer "asset_subsystem_id", limit: 4
    t.integer "parts_cost",         limit: 4
    t.integer "labor_cost",         limit: 4
  end

  add_index "asset_event_asset_subsystems", ["asset_event_id"], name: "rehab_events_subsystems_idx1", using: :btree
  add_index "asset_event_asset_subsystems", ["asset_subsystem_id"], name: "rehab_events_subsystems_idx2", using: :btree

  create_table "asset_event_types", force: :cascade do |t|
    t.string  "name",              limit: 64,  null: false
    t.string  "class_name",        limit: 64,  null: false
    t.string  "job_name",          limit: 64,  null: false
    t.string  "display_icon_name", limit: 64,  null: false
    t.string  "description",       limit: 254, null: false
    t.boolean "active",                        null: false
  end

  add_index "asset_event_types", ["class_name"], name: "asset_event_types_idx1", using: :btree

  create_table "asset_events", force: :cascade do |t|
    t.string   "object_key",                  limit: 12,                            null: false
    t.integer  "asset_id",                    limit: 4,                             null: false
    t.integer  "asset_event_type_id",         limit: 4,                             null: false
    t.integer  "upload_id",                   limit: 4
    t.date     "event_date",                                                        null: false
    t.decimal  "assessed_rating",                           precision: 9, scale: 2
    t.integer  "condition_type_id",           limit: 4
    t.integer  "current_mileage",             limit: 4
    t.integer  "parent_id",                   limit: 4
    t.integer  "replacement_year",            limit: 4
    t.integer  "rebuild_year",                limit: 4
    t.integer  "disposition_year",            limit: 4
    t.integer  "extended_useful_life_miles",  limit: 4
    t.integer  "extended_useful_life_months", limit: 4
    t.integer  "replacement_reason_type_id",  limit: 4
    t.string   "replacement_status_type_id",  limit: 255
    t.date     "disposition_date"
    t.integer  "disposition_type_id",         limit: 4
    t.integer  "service_status_type_id",      limit: 4
    t.integer  "maintenance_type_id",         limit: 4
    t.integer  "pcnt_5311_routes",            limit: 4
    t.integer  "avg_daily_use_hours",         limit: 4
    t.integer  "avg_daily_use_miles",         limit: 4
    t.integer  "avg_daily_passenger_trips",   limit: 4
    t.decimal  "avg_cost_per_mile",                         precision: 9, scale: 2
    t.decimal  "avg_miles_per_gallon",                      precision: 9, scale: 2
    t.integer  "annual_maintenance_cost",     limit: 4
    t.integer  "annual_insurance_cost",       limit: 4
    t.boolean  "actual_costs"
    t.integer  "annual_affected_ridership",   limit: 4
    t.integer  "annual_dollars_generated",    limit: 4
    t.integer  "sales_proceeds",              limit: 4
    t.string   "organization_id",             limit: 255
    t.text     "comments",                    limit: 65535
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.string   "state",                       limit: 32
    t.string   "document",                    limit: 128
    t.string   "original_filename",           limit: 128
    t.integer  "created_by_id",               limit: 4
    t.integer  "total_cost",                  limit: 4
  end

  add_index "asset_events", ["asset_event_type_id"], name: "asset_events_idx3", using: :btree
  add_index "asset_events", ["asset_id"], name: "asset_events_idx2", using: :btree
  add_index "asset_events", ["created_by_id"], name: "asset_events_creator_idx", using: :btree
  add_index "asset_events", ["event_date"], name: "asset_events_idx4", using: :btree
  add_index "asset_events", ["object_key"], name: "asset_events_idx1", using: :btree
  add_index "asset_events", ["upload_id"], name: "asset_events_idx5", using: :btree

  create_table "asset_groups", force: :cascade do |t|
    t.string   "object_key",      limit: 12,  null: false
    t.integer  "organization_id", limit: 4,   null: false
    t.string   "name",            limit: 64,  null: false
    t.string   "code",            limit: 8,   null: false
    t.string   "description",     limit: 254
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "asset_groups", ["object_key"], name: "asset_groups_idx1", using: :btree
  add_index "asset_groups", ["organization_id"], name: "asset_groups_idx2", using: :btree

  create_table "asset_groups_assets", id: false, force: :cascade do |t|
    t.integer "asset_id",       limit: 4, null: false
    t.integer "asset_group_id", limit: 4, null: false
  end

  add_index "asset_groups_assets", ["asset_id", "asset_group_id"], name: "asset_groups_assets_idx1", using: :btree

  create_table "asset_subsystems", force: :cascade do |t|
    t.string  "name",          limit: 64
    t.string  "code",          limit: 2
    t.string  "description",   limit: 254
    t.integer "asset_type_id", limit: 4
    t.boolean "active"
  end

  create_table "asset_subtypes", force: :cascade do |t|
    t.integer "asset_type_id", limit: 4,   null: false
    t.string  "name",          limit: 64,  null: false
    t.string  "description",   limit: 254, null: false
    t.string  "image",         limit: 254
    t.boolean "active",                    null: false
  end

  add_index "asset_subtypes", ["asset_type_id"], name: "asset_subtypes_idx1", using: :btree

  create_table "asset_tags", force: :cascade do |t|
    t.integer "asset_id", limit: 4
    t.integer "user_id",  limit: 4
  end

  add_index "asset_tags", ["asset_id"], name: "asset_tags_idx1", using: :btree
  add_index "asset_tags", ["user_id"], name: "asset_tags_idx2", using: :btree

  create_table "asset_types", force: :cascade do |t|
    t.string  "name",              limit: 64,  null: false
    t.string  "class_name",        limit: 64,  null: false
    t.string  "display_icon_name", limit: 64,  null: false
    t.string  "map_icon_name",     limit: 64,  null: false
    t.string  "description",       limit: 254, null: false
    t.boolean "allow_parent"
    t.boolean "active",                        null: false
  end

  add_index "asset_types", ["class_name"], name: "asset_types_idx1", using: :btree
  add_index "asset_types", ["name"], name: "asset_types_idx2", using: :btree

  create_table "asset_types_manufacturers", id: false, force: :cascade do |t|
    t.integer "asset_type_id",   limit: 4
    t.integer "manufacturer_id", limit: 4
  end

  add_index "asset_types_manufacturers", ["asset_type_id", "manufacturer_id"], name: "asset_types_manufacturers_idx1", using: :btree

  create_table "assets", force: :cascade do |t|
    t.string   "object_key",                      limit: 12,                             null: false
    t.integer  "organization_id",                 limit: 4,                              null: false
    t.integer  "asset_type_id",                   limit: 4,                              null: false
    t.integer  "asset_subtype_id",                limit: 4,                              null: false
    t.string   "asset_tag",                       limit: 32,                             null: false
    t.string   "external_id",                     limit: 32
    t.integer  "parent_id",                       limit: 4
    t.integer  "superseded_by_id",                limit: 4
    t.integer  "manufacturer_id",                 limit: 4
    t.string   "other_manufacturer",              limit: 255
    t.string   "manufacturer_model",              limit: 128
    t.integer  "manufacture_year",                limit: 4
    t.integer  "pcnt_capital_responsibility",     limit: 4
    t.integer  "vendor_id",                       limit: 4
    t.integer  "policy_replacement_year",         limit: 4
    t.integer  "policy_rehabilitation_year",      limit: 4
    t.integer  "estimated_replacement_year",      limit: 4
    t.integer  "estimated_replacement_cost",      limit: 4
    t.integer  "scheduled_replacement_year",      limit: 4
    t.integer  "scheduled_rehabilitation_year",   limit: 4
    t.integer  "scheduled_disposition_year",      limit: 4
    t.integer  "scheduled_replacement_cost",      limit: 4
    t.text     "early_replacement_reason",        limit: 65535
    t.boolean  "scheduled_replace_with_new"
    t.integer  "scheduled_rehabilitation_cost",   limit: 4
    t.integer  "replacement_reason_type_id",      limit: 4
    t.string   "replacement_status_type_id",      limit: 255
    t.boolean  "in_backlog"
    t.integer  "reported_condition_type_id",      limit: 4
    t.decimal  "reported_condition_rating",                     precision: 10, scale: 1
    t.integer  "reported_mileage",                limit: 4
    t.date     "reported_mileage_date"
    t.date     "reported_condition_date"
    t.integer  "estimated_condition_type_id",     limit: 4
    t.decimal  "estimated_condition_rating",                    precision: 9,  scale: 2
    t.integer  "service_status_type_id",          limit: 4
    t.date     "service_status_date"
    t.date     "last_maintenance_date"
    t.boolean  "depreciable"
    t.integer  "book_value",                      limit: 4
    t.integer  "salvage_value",                   limit: 4
    t.date     "disposition_date"
    t.integer  "disposition_type_id",             limit: 4
    t.date     "last_rehabilitation_date"
    t.string   "location_reference",              limit: 254
    t.text     "location_comments",               limit: 65535
    t.integer  "fuel_type_id",                    limit: 4
    t.integer  "vehicle_length",                  limit: 4
    t.integer  "gross_vehicle_weight",            limit: 4
    t.string   "title_number",                    limit: 32
    t.string   "serial_number",                   limit: 32
    t.boolean  "purchased_new"
    t.integer  "purchase_cost",                   limit: 4
    t.date     "purchase_date"
    t.date     "warranty_date"
    t.date     "in_service_date"
    t.integer  "expected_useful_life",            limit: 4
    t.integer  "expected_useful_miles",           limit: 4
    t.integer  "rebuild_year",                    limit: 4
    t.string   "license_plate",                   limit: 32
    t.integer  "seating_capacity",                limit: 4
    t.integer  "standing_capacity",               limit: 4
    t.integer  "wheelchair_capacity",             limit: 4
    t.integer  "fta_ownership_type_id",           limit: 4
    t.integer  "fta_vehicle_type_id",             limit: 4
    t.integer  "fta_funding_type_id",             limit: 4
    t.boolean  "ada_accessible_lift"
    t.boolean  "ada_accessible_ramp"
    t.boolean  "fta_emergency_contingency_fleet"
    t.string   "description",                     limit: 128
    t.string   "address1",                        limit: 128
    t.string   "address2",                        limit: 128
    t.string   "city",                            limit: 64
    t.string   "state",                           limit: 2
    t.string   "zip",                             limit: 10
    t.integer  "facility_size",                   limit: 4
    t.boolean  "section_of_larger_facility"
    t.integer  "pcnt_operational",                limit: 4
    t.integer  "num_floors",                      limit: 4
    t.integer  "num_structures",                  limit: 4
    t.integer  "num_elevators",                   limit: 4
    t.integer  "num_escalators",                  limit: 4
    t.integer  "num_parking_spaces_public",       limit: 4
    t.integer  "num_parking_spaces_private",      limit: 4
    t.decimal  "lot_size",                                      precision: 9,  scale: 2
    t.string   "line_number",                     limit: 128
    t.integer  "quantity",                        limit: 4
    t.string   "quantity_units",                  limit: 16
    t.integer  "created_by_id",                   limit: 4
    t.integer  "weight",                          limit: 4
    t.integer  "updated_by_id",                   limit: 4
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.integer  "upload_id",                       limit: 4
    t.integer  "location_id",                     limit: 4
    t.integer  "dual_fuel_type_id",               limit: 4
  end

  add_index "assets", ["asset_subtype_id"], name: "assets_idx4", using: :btree
  add_index "assets", ["asset_type_id"], name: "assets_idx3", using: :btree
  add_index "assets", ["estimated_replacement_year"], name: "assets_idx8", using: :btree
  add_index "assets", ["in_backlog"], name: "assets_idx7", using: :btree
  add_index "assets", ["manufacture_year"], name: "assets_idx5", using: :btree
  add_index "assets", ["object_key"], name: "assets_idx1", using: :btree
  add_index "assets", ["organization_id", "asset_subtype_id", "in_backlog"], name: "assets_idx12", using: :btree
  add_index "assets", ["organization_id", "asset_subtype_id", "policy_replacement_year"], name: "assets_idx10", using: :btree
  add_index "assets", ["organization_id", "in_backlog"], name: "assets_idx11", using: :btree
  add_index "assets", ["organization_id", "policy_replacement_year"], name: "assets_idx9", using: :btree
  add_index "assets", ["organization_id"], name: "assets_idx2", using: :btree
  add_index "assets", ["reported_condition_type_id"], name: "assets_idx6", using: :btree
  add_index "assets", ["superseded_by_id"], name: "assets_idx13", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "object_key",       limit: 12,  null: false
    t.integer  "commentable_id",   limit: 4,   null: false
    t.string   "commentable_type", limit: 64,  null: false
    t.string   "comment",          limit: 254, null: false
    t.integer  "created_by_id",    limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "comments_idx1", using: :btree

  create_table "condition_estimation_types", force: :cascade do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "class_name",  limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  add_index "condition_estimation_types", ["class_name"], name: "condition_estimation_types_idx1", using: :btree

  create_table "condition_rollup_calculation_types", force: :cascade do |t|
    t.string  "name",        limit: 255
    t.string  "class_name",  limit: 255
    t.string  "description", limit: 255
    t.boolean "active"
  end

  create_table "condition_type_percents", force: :cascade do |t|
    t.integer  "asset_event_id",    limit: 4
    t.integer  "condition_type_id", limit: 4
    t.integer  "pcnt",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "condition_type_percents", ["asset_event_id"], name: "index_condition_type_percents_on_asset_event_id", using: :btree
  add_index "condition_type_percents", ["condition_type_id"], name: "index_condition_type_percents_on_condition_type_id", using: :btree

  create_table "condition_types", force: :cascade do |t|
    t.string  "name",        limit: 64,                          null: false
    t.decimal "rating",                  precision: 9, scale: 2, null: false
    t.string  "description", limit: 254,                         null: false
    t.boolean "active",                                          null: false
  end

  create_table "cost_calculation_types", force: :cascade do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "class_name",  limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  add_index "cost_calculation_types", ["class_name"], name: "cost_calculation_types_idx1", using: :btree

  create_table "customers", force: :cascade do |t|
    t.integer  "license_type_id", limit: 4,  null: false
    t.string   "name",            limit: 64, null: false
    t.boolean  "active",                     null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "delayed_job_priorities", force: :cascade do |t|
    t.string   "class_name", limit: 255, null: false
    t.integer  "priority",   limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4
    t.integer  "attempts",   limit: 4
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "disposition_types", force: :cascade do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 2,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string   "object_key",        limit: 12,  null: false
    t.integer  "documentable_id",   limit: 4,   null: false
    t.string   "documentable_type", limit: 64,  null: false
    t.string   "document",          limit: 128, null: false
    t.string   "description",       limit: 254, null: false
    t.string   "original_filename", limit: 128, null: false
    t.string   "content_type",      limit: 128, null: false
    t.integer  "file_size",         limit: 4,   null: false
    t.integer  "created_by_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "documents", ["documentable_id", "documentable_type"], name: "documents_idx2", using: :btree
  add_index "documents", ["object_key"], name: "documents_idx1", using: :btree

  create_table "dual_fuel_types", force: :cascade do |t|
    t.integer "primary_fuel_type_id",   limit: 4
    t.integer "secondary_fuel_type_id", limit: 4
    t.boolean "active"
  end

  add_index "dual_fuel_types", ["primary_fuel_type_id"], name: "index_dual_fuel_types_on_primary_fuel_type_id", using: :btree
  add_index "dual_fuel_types", ["secondary_fuel_type_id"], name: "index_dual_fuel_types_on_secondary_fuel_type_id", using: :btree

  create_table "file_content_types", force: :cascade do |t|
    t.string  "name",         limit: 64,  null: false
    t.string  "class_name",   limit: 64,  null: false
    t.string  "builder_name", limit: 255
    t.string  "description",  limit: 254, null: false
    t.boolean "active",                   null: false
  end

  add_index "file_content_types", ["class_name"], name: "file_content_types_idx2", using: :btree
  add_index "file_content_types", ["name"], name: "file_content_types_idx1", using: :btree

  create_table "file_status_types", force: :cascade do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  add_index "file_status_types", ["name"], name: "file_status_types_idx1", using: :btree

  create_table "forms", force: :cascade do |t|
    t.string   "object_key",  limit: 12,  null: false
    t.string   "name",        limit: 64,  null: false
    t.string   "description", limit: 254, null: false
    t.string   "roles",       limit: 128, null: false
    t.string   "controller",  limit: 64,  null: false
    t.boolean  "active",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forms", ["object_key"], name: "forms_idx1", using: :btree

  create_table "frequency_types", force: :cascade do |t|
    t.string  "name",        limit: 32,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fuel_types", force: :cascade do |t|
    t.string  "name",        limit: 255, null: false
    t.string  "code",        limit: 255, null: false
    t.string  "description", limit: 255, null: false
    t.boolean "active",                  null: false
  end

  create_table "images", force: :cascade do |t|
    t.string   "object_key",        limit: 12,  null: false
    t.integer  "imagable_id",       limit: 4,   null: false
    t.string   "imagable_type",     limit: 64,  null: false
    t.string   "image",             limit: 128, null: false
    t.string   "description",       limit: 254, null: false
    t.string   "original_filename", limit: 128, null: false
    t.string   "content_type",      limit: 128, null: false
    t.integer  "file_size",         limit: 4,   null: false
    t.integer  "created_by_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["imagable_id", "imagable_type"], name: "images_idx2", using: :btree
  add_index "images", ["object_key"], name: "images_idx1", using: :btree

  create_table "issue_status_types", force: :cascade do |t|
    t.string  "name",        limit: 32,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active"
  end

  create_table "issue_types", force: :cascade do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "issues", force: :cascade do |t|
    t.string   "object_key",           limit: 12,                null: false
    t.integer  "issue_type_id",        limit: 4,                 null: false
    t.integer  "web_browser_type_id",  limit: 4,                 null: false
    t.integer  "created_by_id",        limit: 4,                 null: false
    t.text     "comments",             limit: 65535,             null: false
    t.integer  "issue_status_type_id", limit: 4,     default: 1
    t.text     "resolution_comments",  limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issues", ["issue_type_id"], name: "issues_idx2", using: :btree
  add_index "issues", ["object_key"], name: "issues_idx1", using: :btree

  create_table "keyword_search_indices", force: :cascade do |t|
    t.string   "object_class",    limit: 64,    null: false
    t.string   "object_key",      limit: 12,    null: false
    t.integer  "organization_id", limit: 4,     null: false
    t.string   "context",         limit: 64,    null: false
    t.string   "summary",         limit: 64,    null: false
    t.text     "search_text",     limit: 65535, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keyword_search_indices", ["object_class"], name: "keyword_search_indices_idx1", using: :btree

  create_table "license_types", force: :cascade do |t|
    t.string  "name",          limit: 64,  null: false
    t.string  "description",   limit: 254, null: false
    t.boolean "asset_manager",             null: false
    t.boolean "web_services",              null: false
    t.boolean "active",                    null: false
  end

  create_table "maintenance_types", force: :cascade do |t|
    t.string  "name",        limit: 32,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "manufacturers", force: :cascade do |t|
    t.string  "filter", limit: 32,  null: false
    t.string  "name",   limit: 128, null: false
    t.string  "code",   limit: 3,   null: false
    t.boolean "active",             null: false
  end

  add_index "manufacturers", ["filter"], name: "manufacturers_idx1", using: :btree

  create_table "message_tags", force: :cascade do |t|
    t.integer "message_id", limit: 4
    t.integer "user_id",    limit: 4
  end

  add_index "message_tags", ["message_id"], name: "message_tags_idx1", using: :btree
  add_index "message_tags", ["user_id"], name: "message_tags_idx2", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "object_key",        limit: 12,    null: false
    t.integer  "organization_id",   limit: 4,     null: false
    t.integer  "user_id",           limit: 4,     null: false
    t.integer  "to_user_id",        limit: 4
    t.integer  "priority_type_id",  limit: 4,     null: false
    t.integer  "thread_message_id", limit: 4
    t.string   "subject",           limit: 64,    null: false
    t.text     "body",              limit: 65535
    t.boolean  "active"
    t.datetime "opened_at"
    t.datetime "created_at",                      null: false
  end

  add_index "messages", ["object_key"], name: "messages_idx1", using: :btree
  add_index "messages", ["organization_id"], name: "messages_idx2", using: :btree
  add_index "messages", ["thread_message_id"], name: "messages_idx5", using: :btree
  add_index "messages", ["to_user_id"], name: "messages_idx4", using: :btree
  add_index "messages", ["user_id"], name: "messages_idx3", using: :btree

  create_table "notice_types", force: :cascade do |t|
    t.string  "name",          limit: 64,  null: false
    t.string  "description",   limit: 254, null: false
    t.string  "display_icon",  limit: 64,  null: false
    t.string  "display_class", limit: 64,  null: false
    t.boolean "active"
  end

  create_table "notices", force: :cascade do |t|
    t.string   "object_key",       limit: 12,    null: false
    t.string   "subject",          limit: 64,    null: false
    t.string   "summary",          limit: 128,   null: false
    t.text     "details",          limit: 65535
    t.integer  "notice_type_id",   limit: 4
    t.integer  "organization_id",  limit: 4
    t.datetime "display_datetime"
    t.datetime "end_datetime"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "object_key",      limit: 12,  null: false
    t.string   "text",            limit: 255, null: false
    t.string   "link",            limit: 255, null: false
    t.integer  "notifiable_id",   limit: 4
    t.string   "notifiable_type", limit: 255
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["notifiable_id", "notifiable_type"], name: "index_notifications_on_notifiable_id_and_notifiable_type", using: :btree

  create_table "organization_role_mappings", force: :cascade do |t|
    t.integer  "organization_id", limit: 4, null: false
    t.integer  "role_id",         limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_types", force: :cascade do |t|
    t.string  "name",              limit: 64,  null: false
    t.string  "class_name",        limit: 64,  null: false
    t.string  "display_icon_name", limit: 64,  null: false
    t.string  "map_icon_name",     limit: 64,  null: false
    t.string  "description",       limit: 254, null: false
    t.string  "roles",             limit: 255
    t.boolean "active",                        null: false
  end

  add_index "organization_types", ["class_name"], name: "organization_types_idx1", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.integer  "organization_type_id", limit: 4,                            null: false
    t.integer  "customer_id",          limit: 4,                            null: false
    t.string   "external_id",          limit: 32
    t.string   "name",                 limit: 128,                          null: false
    t.string   "short_name",           limit: 16,                           null: false
    t.boolean  "license_holder",                                            null: false
    t.string   "address1",             limit: 128,                          null: false
    t.string   "address2",             limit: 128
    t.string   "county",               limit: 64
    t.string   "city",                 limit: 64,                           null: false
    t.string   "state",                limit: 2,                            null: false
    t.string   "zip",                  limit: 10,                           null: false
    t.string   "phone",                limit: 12,                           null: false
    t.string   "phone_ext",            limit: 6
    t.string   "fax",                  limit: 10
    t.string   "url",                  limit: 128,                          null: false
    t.boolean  "indian_tribe"
    t.string   "subrecipient_number",  limit: 9
    t.string   "ntd_id_number",        limit: 4
    t.boolean  "active",                                                    null: false
    t.decimal  "latitude",                         precision: 11, scale: 6
    t.decimal  "longitude",                        precision: 11, scale: 6
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
  end

  add_index "organizations", ["customer_id"], name: "organizations_idx2", using: :btree
  add_index "organizations", ["organization_type_id"], name: "organizations_idx1", using: :btree
  add_index "organizations", ["short_name"], name: "organizations_idx4", using: :btree
  add_index "organizations", ["short_name"], name: "short_name", using: :btree

  create_table "organizations_saved_searches", force: :cascade do |t|
    t.integer "organization_id", limit: 4
    t.integer "saved_search_id", limit: 4
  end

  add_index "organizations_saved_searches", ["organization_id"], name: "index_organizations_saved_searches_on_organization_id", using: :btree
  add_index "organizations_saved_searches", ["saved_search_id"], name: "index_organizations_saved_searches_on_saved_search_id", using: :btree

  create_table "policies", force: :cascade do |t|
    t.string   "object_key",                       limit: 12,                          null: false
    t.integer  "organization_id",                  limit: 4,                           null: false
    t.integer  "parent_id",                        limit: 4
    t.integer  "year",                             limit: 4,                           null: false
    t.string   "name",                             limit: 64,                          null: false
    t.string   "description",                      limit: 254,                         null: false
    t.integer  "service_life_calculation_type_id", limit: 4,                           null: false
    t.integer  "cost_calculation_type_id",         limit: 4,                           null: false
    t.integer  "condition_estimation_type_id",     limit: 4,                           null: false
    t.decimal  "condition_threshold",                          precision: 9, scale: 2, null: false
    t.decimal  "interest_rate",                                precision: 9, scale: 2, null: false
    t.boolean  "current",                                                              null: false
    t.boolean  "active",                                                               null: false
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
  end

  add_index "policies", ["object_key"], name: "policies_idx1", using: :btree
  add_index "policies", ["organization_id"], name: "policies_idx2", using: :btree

  create_table "policy_asset_subtype_rules", force: :cascade do |t|
    t.integer  "policy_id",                             limit: 4, null: false
    t.integer  "asset_subtype_id",                      limit: 4, null: false
    t.integer  "fuel_type_id",                          limit: 4
    t.integer  "min_service_life_months",               limit: 4, null: false
    t.integer  "min_service_life_miles",                limit: 4
    t.integer  "replacement_cost",                      limit: 4, null: false
    t.integer  "cost_fy_year",                          limit: 4, null: false
    t.boolean  "replace_with_new",                                null: false
    t.boolean  "replace_with_leased",                             null: false
    t.integer  "replace_asset_subtype_id",              limit: 4
    t.integer  "replace_fuel_type_id",                  limit: 4
    t.integer  "lease_length_months",                   limit: 4
    t.integer  "rehabilitation_service_month",          limit: 4
    t.integer  "rehabilitation_labor_cost",             limit: 4
    t.integer  "rehabilitation_parts_cost",             limit: 4
    t.integer  "extended_service_life_months",          limit: 4
    t.integer  "extended_service_life_miles",           limit: 4
    t.integer  "min_used_purchase_service_life_months", limit: 4, null: false
    t.string   "purchase_replacement_code",             limit: 8, null: false
    t.string   "lease_replacement_code",                limit: 8
    t.string   "purchase_expansion_code",               limit: 8
    t.string   "lease_expansion_code",                  limit: 8
    t.string   "rehabilitation_code",                   limit: 8, null: false
    t.string   "engineering_design_code",               limit: 8
    t.string   "construction_code",                     limit: 8
    t.boolean  "default_rule"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "policy_asset_subtype_rules", ["asset_subtype_id"], name: "policy_asset_subtype_rules_idx2", using: :btree
  add_index "policy_asset_subtype_rules", ["policy_id"], name: "policy_asset_subtype_rules_idx1", using: :btree

  create_table "policy_asset_type_rules", force: :cascade do |t|
    t.integer  "policy_id",                            limit: 4,                         null: false
    t.integer  "asset_type_id",                        limit: 4,                         null: false
    t.integer  "service_life_calculation_type_id",     limit: 4,                         null: false
    t.integer  "replacement_cost_calculation_type_id", limit: 4,                         null: false
    t.integer  "condition_rollup_calculation_type_id", limit: 4
    t.decimal  "annual_inflation_rate",                          precision: 9, scale: 2, null: false
    t.integer  "pcnt_residual_value",                  limit: 4,                         null: false
    t.integer  "condition_rollup_weight",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "policy_asset_type_rules", ["asset_type_id"], name: "policy_asset_type_rules_idx2", using: :btree
  add_index "policy_asset_type_rules", ["policy_id"], name: "policy_asset_type_rules_idx1", using: :btree

  create_table "priority_types", force: :cascade do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "is_default",              null: false
    t.boolean "active",                  null: false
  end

  create_table "query_params", force: :cascade do |t|
    t.string  "name",         limit: 255
    t.string  "description",  limit: 255
    t.text    "query_string", limit: 65535
    t.string  "class_name",   limit: 255
    t.boolean "active"
  end

  create_table "replacement_reason_types", force: :cascade do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active"
  end

  create_table "replacement_status_types", force: :cascade do |t|
    t.string  "name",        limit: 255
    t.string  "description", limit: 255
    t.boolean "active"
  end

  create_table "report_types", force: :cascade do |t|
    t.string  "name",              limit: 64,  null: false
    t.string  "description",       limit: 254, null: false
    t.string  "display_icon_name", limit: 64,  null: false
    t.boolean "active",                        null: false
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "report_type_id",    limit: 4,     null: false
    t.string   "name",              limit: 64,    null: false
    t.string   "description",       limit: 254,   null: false
    t.string   "class_name",        limit: 255,   null: false
    t.string   "view_name",         limit: 32,    null: false
    t.string   "roles",             limit: 128
    t.text     "custom_sql",        limit: 65535
    t.boolean  "show_in_nav"
    t.boolean  "show_in_dashboard"
    t.string   "chart_type",        limit: 32
    t.text     "chart_options",     limit: 65535
    t.boolean  "active",                          null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "reports", ["report_type_id"], name: "reports_idx1", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",              limit: 64,                  null: false
    t.integer  "weight",            limit: 4
    t.integer  "resource_id",       limit: 4
    t.string   "resource_type",     limit: 255
    t.integer  "role_parent_id",    limit: 4
    t.boolean  "show_in_user_mgmt"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "privilege",                     default: false, null: false
    t.string   "label",             limit: 255
  end

  add_index "roles", ["name"], name: "roles_idx1", using: :btree
  add_index "roles", ["resource_id"], name: "roles_idx2", using: :btree

  create_table "rule_sets", force: :cascade do |t|
    t.string  "object_key",     limit: 255
    t.string  "name",           limit: 255
    t.string  "class_name",     limit: 255
    t.boolean "rule_set_aware"
    t.boolean "active"
  end

  create_table "saved_searches", force: :cascade do |t|
    t.string   "object_key",     limit: 12,    null: false
    t.integer  "user_id",        limit: 4,     null: false
    t.string   "name",           limit: 64,    null: false
    t.string   "description",    limit: 254,   null: false
    t.integer  "search_type_id", limit: 4
    t.text     "json",           limit: 65535
    t.text     "query_string",   limit: 65535
    t.integer  "ordinal",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_types", force: :cascade do |t|
    t.string  "name",       limit: 255
    t.string  "class_name", limit: 255
    t.boolean "active"
  end

  create_table "service_life_calculation_types", force: :cascade do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "class_name",  limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  add_index "service_life_calculation_types", ["class_name"], name: "service_life_calculation_types_idx1", using: :btree

  create_table "service_status_types", force: :cascade do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 1,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "system_configs", force: :cascade do |t|
    t.integer  "customer_id",           limit: 4
    t.string   "start_of_fiscal_year",  limit: 5
    t.string   "map_tile_provider",     limit: 64
    t.integer  "srid",                  limit: 4
    t.float    "min_lat",               limit: 24
    t.float    "min_lon",               limit: 24
    t.float    "max_lat",               limit: 24
    t.float    "max_lon",               limit: 24
    t.integer  "search_radius",         limit: 4
    t.string   "search_units",          limit: 8
    t.string   "geocoder_components",   limit: 128
    t.string   "geocoder_region",       limit: 64
    t.integer  "num_forecasting_years", limit: 4
    t.integer  "num_reporting_years",   limit: 4
    t.string   "asset_base_class_name", limit: 64
    t.integer  "max_rows_returned",     limit: 4
    t.string   "data_file_path",        limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "object_key",          limit: 12,    null: false
    t.integer  "taskable_id",         limit: 4
    t.string   "taskable_type",       limit: 255
    t.integer  "user_id",             limit: 4,     null: false
    t.integer  "priority_type_id",    limit: 4,     null: false
    t.integer  "organization_id",     limit: 4,     null: false
    t.integer  "assigned_to_user_id", limit: 4
    t.string   "subject",             limit: 64,    null: false
    t.text     "body",                limit: 65535, null: false
    t.boolean  "send_reminder"
    t.string   "state",               limit: 32
    t.datetime "complete_by",                       null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "tasks", ["assigned_to_user_id"], name: "tasks_idx5", using: :btree
  add_index "tasks", ["complete_by"], name: "tasks_idx6", using: :btree
  add_index "tasks", ["object_key"], name: "tasks_idx1", using: :btree
  add_index "tasks", ["organization_id"], name: "tasks_idx4", using: :btree
  add_index "tasks", ["state"], name: "tasks_idx3", using: :btree
  add_index "tasks", ["user_id"], name: "tasks_idx2", using: :btree

  create_table "uploads", force: :cascade do |t|
    t.string   "object_key",              limit: 12,         null: false
    t.integer  "organization_id",         limit: 4
    t.integer  "user_id",                 limit: 4,          null: false
    t.integer  "file_content_type_id",    limit: 4,          null: false
    t.integer  "file_status_type_id",     limit: 4,          null: false
    t.string   "file",                    limit: 128,        null: false
    t.string   "original_filename",       limit: 254,        null: false
    t.integer  "num_rows_processed",      limit: 4
    t.integer  "num_rows_added",          limit: 4
    t.integer  "num_rows_replaced",       limit: 4
    t.integer  "num_rows_skipped",        limit: 4
    t.integer  "num_rows_failed",         limit: 4
    t.text     "processing_log",          limit: 4294967295
    t.boolean  "force_update"
    t.datetime "processing_started_at"
    t.datetime "processing_completed_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "uploads", ["file_content_type_id"], name: "uploads_idx4", using: :btree
  add_index "uploads", ["file_status_type_id"], name: "uploads_idx5", using: :btree
  add_index "uploads", ["object_key"], name: "uploads_idx1", using: :btree
  add_index "uploads", ["organization_id"], name: "uploads_idx2", using: :btree
  add_index "uploads", ["user_id"], name: "uploads_idx3", using: :btree

  create_table "user_notifications", force: :cascade do |t|
    t.integer  "user_id",         limit: 4, null: false
    t.integer  "notification_id", limit: 4, null: false
    t.datetime "opened_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_notifications", ["notification_id"], name: "index_user_notifications_on_notification_id", using: :btree
  add_index "user_notifications", ["user_id"], name: "index_user_notifications_on_user_id", using: :btree

  create_table "user_organization_filters", force: :cascade do |t|
    t.string   "object_key",         limit: 12,    null: false
    t.string   "name",               limit: 64,    null: false
    t.string   "description",        limit: 254,   null: false
    t.boolean  "active",                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order",         limit: 4
    t.integer  "created_by_user_id", limit: 4
    t.text     "query_string",       limit: 65535
    t.integer  "resource_id",        limit: 4
    t.string   "resource_type",      limit: 255
  end

  add_index "user_organization_filters", ["created_by_user_id"], name: "index_user_organization_filters_on_created_by_user_id", using: :btree
  add_index "user_organization_filters", ["object_key"], name: "user_organization_filters_idx1", using: :btree

  create_table "user_organization_filters_organizations", id: false, force: :cascade do |t|
    t.integer "user_organization_filter_id", limit: 4, null: false
    t.integer "organization_id",             limit: 4, null: false
  end

  add_index "user_organization_filters_organizations", ["user_organization_filter_id", "organization_id"], name: "user_organization_filters_idx1", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "object_key",                  limit: 12,  null: false
    t.integer  "organization_id",             limit: 4,   null: false
    t.string   "external_id",                 limit: 32
    t.string   "first_name",                  limit: 64,  null: false
    t.string   "last_name",                   limit: 64,  null: false
    t.string   "title",                       limit: 64
    t.string   "phone",                       limit: 12,  null: false
    t.string   "phone_ext",                   limit: 6
    t.string   "timezone",                    limit: 32,  null: false
    t.string   "email",                       limit: 128, null: false
    t.string   "address1",                    limit: 64
    t.string   "address2",                    limit: 64
    t.string   "city",                        limit: 32
    t.string   "state",                       limit: 2
    t.string   "zip",                         limit: 10
    t.integer  "num_table_rows",              limit: 4
    t.integer  "user_organization_filter_id", limit: 4
    t.string   "encrypted_password",          limit: 64,  null: false
    t.string   "reset_password_token",        limit: 64
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               limit: 4
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",          limit: 16
    t.string   "last_sign_in_ip",             limit: 16
    t.integer  "failed_attempts",             limit: 4,   null: false
    t.string   "unlock_token",                limit: 128
    t.datetime "locked_at"
    t.boolean  "notify_via_email",                        null: false
    t.integer  "weather_code_id",             limit: 4
    t.boolean  "active",                                  null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "users", ["email"], name: "users_idx3", using: :btree
  add_index "users", ["object_key"], name: "users_idx1", using: :btree
  add_index "users", ["organization_id"], name: "users_idx2", using: :btree

  create_table "users_organizations", id: false, force: :cascade do |t|
    t.integer "user_id",         limit: 4
    t.integer "organization_id", limit: 4
  end

  add_index "users_organizations", ["user_id", "organization_id"], name: "users_organizations_idx2", using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer  "user_id",            limit: 4, null: false
    t.integer  "role_id",            limit: 4, null: false
    t.integer  "granted_by_user_id", limit: 4
    t.date     "granted_on_date"
    t.integer  "revoked_by_user_id", limit: 4
    t.date     "revoked_on_date"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users_roles", ["active"], name: "users_roles_idx3", using: :btree
  add_index "users_roles", ["user_id", "role_id"], name: "users_roles_idx2", using: :btree

  create_table "users_user_organization_filters", force: :cascade do |t|
    t.integer "user_id",                     limit: 4, null: false
    t.integer "user_organization_filter_id", limit: 4, null: false
  end

  add_index "users_user_organization_filters", ["user_id"], name: "users_user_organization_filters_idx1", using: :btree
  add_index "users_user_organization_filters", ["user_organization_filter_id"], name: "users_user_organization_filters_idx2", using: :btree

  create_table "users_viewable_organizations", force: :cascade do |t|
    t.integer "user_id",         limit: 4
    t.integer "organization_id", limit: 4
  end

  create_table "vendors", force: :cascade do |t|
    t.string   "object_key",      limit: 12,                           null: false
    t.integer  "organization_id", limit: 4,                            null: false
    t.string   "name",            limit: 64,                           null: false
    t.string   "address1",        limit: 64
    t.string   "address2",        limit: 64
    t.string   "city",            limit: 64
    t.string   "state",           limit: 2
    t.string   "zip",             limit: 10
    t.string   "phone",           limit: 12
    t.string   "phone_ext",       limit: 6
    t.string   "fax",             limit: 12
    t.string   "url",             limit: 128
    t.decimal  "latitude",                    precision: 11, scale: 6
    t.decimal  "longitude",                   precision: 11, scale: 6
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vendors", ["name"], name: "vendors_idx2", using: :btree
  add_index "vendors", ["object_key"], name: "vendors_idx1", using: :btree
  add_index "vendors", ["organization_id"], name: "vendors_idx3", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255,   null: false
    t.integer  "item_id",        limit: 4,     null: false
    t.string   "event",          limit: 255,   null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object",         limit: 65535
    t.datetime "created_at"
    t.text     "object_changes", limit: 65535
  end

  create_table "weather_codes", force: :cascade do |t|
    t.string  "state",  limit: 2
    t.string  "code",   limit: 8
    t.string  "city",   limit: 64
    t.boolean "active"
  end

  add_index "weather_codes", ["state", "city"], name: "weather_codes_idx", using: :btree

  create_table "web_browser_types", force: :cascade do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "workflow_events", force: :cascade do |t|
    t.string   "object_key",       limit: 12, null: false
    t.integer  "accountable_id",   limit: 4,  null: false
    t.string   "accountable_type", limit: 64, null: false
    t.string   "event_type",       limit: 64, null: false
    t.integer  "created_by_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_events", ["accountable_id", "accountable_type"], name: "workflow_events_idx2", using: :btree
  add_index "workflow_events", ["object_key"], name: "workflow_events_idx1", using: :btree

end