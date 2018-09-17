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

ActiveRecord::Schema.define(version: 2018_09_12_191549) do

  create_table "activities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12
    t.integer "organization_type_id"
    t.string "name", limit: 64
    t.text "description"
    t.boolean "show_in_dashboard"
    t.boolean "system_activity"
    t.date "start_date"
    t.date "end_date"
    t.integer "frequency_quantity", null: false
    t.integer "frequency_type_id", null: false
    t.string "execution_time", limit: 32, null: false
    t.string "job_name", limit: 64
    t.datetime "last_run"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activity_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.string "item_type", limit: 64, null: false
    t.integer "item_id"
    t.integer "user_id", null: false
    t.text "activity", limit: 4294967295, null: false
    t.datetime "activity_time"
    t.index ["organization_id", "activity_time"], name: "activity_logs_idx1"
    t.index ["user_id", "activity_time"], name: "activity_logs_idx2"
  end

  create_table "archived_fiscal_years", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id"
    t.integer "fy_year"
    t.index ["organization_id"], name: "index_archived_fiscal_years_on_organization_id"
  end

  create_table "asset_event_asset_subsystems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_event_id"
    t.integer "asset_subsystem_id"
    t.integer "parts_cost"
    t.integer "labor_cost"
    t.index ["asset_event_id"], name: "rehab_events_subsystems_idx1"
    t.index ["asset_subsystem_id"], name: "rehab_events_subsystems_idx2"
  end

  create_table "asset_event_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "job_name", limit: 64, null: false
    t.string "display_icon_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["class_name"], name: "asset_event_types_idx1"
  end

  create_table "asset_events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "asset_id"
    t.integer "transam_asset_id"
    t.integer "asset_event_type_id", null: false
    t.integer "upload_id"
    t.date "event_date", null: false
    t.decimal "assessed_rating", precision: 9, scale: 2
    t.integer "condition_type_id"
    t.integer "current_mileage"
    t.integer "parent_id"
    t.integer "replacement_year"
    t.integer "rebuild_year"
    t.integer "disposition_year"
    t.integer "extended_useful_life_miles"
    t.integer "extended_useful_life_months"
    t.integer "replacement_reason_type_id"
    t.string "replacement_status_type_id"
    t.date "disposition_date"
    t.integer "disposition_type_id"
    t.integer "service_status_type_id"
    t.integer "maintenance_type_id"
    t.integer "pcnt_5311_routes"
    t.integer "avg_daily_use_hours"
    t.integer "avg_daily_use_miles"
    t.integer "avg_daily_passenger_trips"
    t.decimal "avg_cost_per_mile", precision: 9, scale: 2
    t.decimal "avg_miles_per_gallon", precision: 9, scale: 2
    t.integer "annual_maintenance_cost"
    t.integer "annual_insurance_cost"
    t.boolean "actual_costs"
    t.integer "annual_affected_ridership"
    t.integer "annual_dollars_generated"
    t.integer "sales_proceeds"
    t.string "organization_id"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state", limit: 32
    t.string "document", limit: 128
    t.string "original_filename", limit: 128
    t.integer "created_by_id"
    t.integer "total_cost"
    t.index ["asset_event_type_id"], name: "asset_events_idx3"
    t.index ["asset_id"], name: "asset_events_idx2"
    t.index ["created_by_id"], name: "asset_events_creator_idx"
    t.index ["event_date"], name: "asset_events_idx4"
    t.index ["object_key"], name: "asset_events_idx1"
    t.index ["upload_id"], name: "asset_events_idx5"
  end

  create_table "asset_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.string "name", limit: 64, null: false
    t.string "code", limit: 8, null: false
    t.string "description", limit: 254
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["object_key"], name: "asset_groups_idx1"
    t.index ["organization_id"], name: "asset_groups_idx2"
  end

  create_table "asset_groups_assets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "transam_asset_id"
    t.integer "asset_group_id", null: false
    t.index ["asset_id", "asset_group_id"], name: "asset_groups_assets_idx1"
  end

  create_table "asset_subsystems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64
    t.string "code", limit: 2
    t.string "description", limit: 254
    t.integer "asset_type_id"
    t.boolean "active"
  end

  create_table "asset_subtypes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_type_id", null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "image", limit: 254
    t.boolean "active", null: false
    t.index ["asset_type_id"], name: "asset_subtypes_idx1"
  end

  create_table "asset_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "user_id"
    t.index ["asset_id"], name: "asset_tags_idx1"
    t.index ["user_id"], name: "asset_tags_idx2"
  end

  create_table "asset_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "display_icon_name", limit: 64, null: false
    t.string "map_icon_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "allow_parent"
    t.boolean "active", null: false
    t.index ["class_name"], name: "asset_types_idx1"
    t.index ["name"], name: "asset_types_idx2"
  end

  create_table "asset_types_manufacturers", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_type_id"
    t.integer "manufacturer_id"
    t.index ["asset_type_id", "manufacturer_id"], name: "asset_types_manufacturers_idx1"
  end

  create_table "assets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.integer "asset_type_id", null: false
    t.integer "asset_subtype_id", null: false
    t.string "asset_tag", limit: 32, null: false
    t.string "external_id", limit: 32
    t.integer "parent_id"
    t.integer "superseded_by_id"
    t.integer "manufacturer_id"
    t.string "other_manufacturer"
    t.string "manufacturer_model", limit: 128
    t.integer "manufacture_year"
    t.integer "pcnt_capital_responsibility"
    t.integer "vendor_id"
    t.integer "policy_replacement_year"
    t.integer "policy_rehabilitation_year"
    t.integer "estimated_replacement_year"
    t.integer "estimated_replacement_cost"
    t.integer "scheduled_replacement_year"
    t.integer "scheduled_rehabilitation_year"
    t.integer "scheduled_disposition_year"
    t.integer "scheduled_replacement_cost"
    t.text "early_replacement_reason"
    t.boolean "scheduled_replace_with_new"
    t.integer "scheduled_rehabilitation_cost"
    t.integer "replacement_reason_type_id"
    t.string "replacement_status_type_id"
    t.boolean "in_backlog"
    t.integer "reported_condition_type_id"
    t.decimal "reported_condition_rating", precision: 10, scale: 1
    t.integer "reported_mileage"
    t.date "reported_mileage_date"
    t.date "reported_condition_date"
    t.integer "estimated_condition_type_id"
    t.decimal "estimated_condition_rating", precision: 9, scale: 2
    t.integer "service_status_type_id"
    t.date "service_status_date"
    t.date "last_maintenance_date"
    t.boolean "depreciable"
    t.integer "book_value"
    t.integer "salvage_value"
    t.date "disposition_date"
    t.integer "disposition_type_id"
    t.date "last_rehabilitation_date"
    t.string "location_reference", limit: 254
    t.text "location_comments"
    t.integer "fuel_type_id"
    t.integer "vehicle_length"
    t.integer "gross_vehicle_weight"
    t.string "title_number", limit: 32
    t.string "serial_number", limit: 32
    t.boolean "purchased_new"
    t.integer "purchase_cost"
    t.date "purchase_date"
    t.date "warranty_date"
    t.date "in_service_date"
    t.integer "expected_useful_life"
    t.integer "expected_useful_miles"
    t.integer "rebuild_year"
    t.string "license_plate", limit: 32
    t.integer "seating_capacity"
    t.integer "standing_capacity"
    t.integer "wheelchair_capacity"
    t.integer "fta_ownership_type_id"
    t.integer "fta_vehicle_type_id"
    t.integer "fta_funding_type_id"
    t.boolean "ada_accessible_lift"
    t.boolean "ada_accessible_ramp"
    t.boolean "fta_emergency_contingency_fleet"
    t.string "description", limit: 128
    t.string "address1", limit: 128
    t.string "address2", limit: 128
    t.string "city", limit: 64
    t.string "state", limit: 2
    t.string "zip", limit: 10
    t.integer "facility_size"
    t.boolean "section_of_larger_facility"
    t.integer "pcnt_operational"
    t.integer "num_floors"
    t.integer "num_structures"
    t.integer "num_elevators"
    t.integer "num_escalators"
    t.integer "num_parking_spaces_public"
    t.integer "num_parking_spaces_private"
    t.decimal "lot_size", precision: 9, scale: 2
    t.string "line_number", limit: 128
    t.integer "quantity"
    t.string "quantity_units", limit: 16
    t.integer "created_by_id"
    t.integer "weight"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "upload_id"
    t.integer "location_id"
    t.integer "dual_fuel_type_id"
    t.index ["asset_subtype_id"], name: "assets_idx4"
    t.index ["asset_type_id"], name: "assets_idx3"
    t.index ["estimated_replacement_year"], name: "assets_idx8"
    t.index ["in_backlog"], name: "assets_idx7"
    t.index ["manufacture_year"], name: "assets_idx5"
    t.index ["object_key"], name: "assets_idx1"
    t.index ["organization_id", "asset_subtype_id", "in_backlog"], name: "assets_idx12"
    t.index ["organization_id", "asset_subtype_id", "policy_replacement_year"], name: "assets_idx10"
    t.index ["organization_id", "in_backlog"], name: "assets_idx11"
    t.index ["organization_id", "policy_replacement_year"], name: "assets_idx9"
    t.index ["organization_id"], name: "assets_idx2"
    t.index ["reported_condition_type_id"], name: "assets_idx6"
    t.index ["superseded_by_id"], name: "assets_idx13"
  end

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "commentable_id", null: false
    t.string "commentable_type", limit: 64, null: false
    t.string "comment", limit: 254, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commentable_id", "commentable_type"], name: "comments_idx1"
  end

  create_table "condition_estimation_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["class_name"], name: "condition_estimation_types_idx1"
  end

  create_table "condition_rollup_calculation_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "class_name"
    t.string "description"
    t.boolean "active"
  end

  create_table "condition_type_percents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_event_id"
    t.integer "condition_type_id"
    t.integer "pcnt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["asset_event_id"], name: "index_condition_type_percents_on_asset_event_id"
    t.index ["condition_type_id"], name: "index_condition_type_percents_on_condition_type_id"
  end

  create_table "condition_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.decimal "rating", precision: 9, scale: 2, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "cost_calculation_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["class_name"], name: "cost_calculation_types_idx1"
  end

  create_table "customers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "license_type_id", null: false
    t.string "name", limit: 64, null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_job_priorities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "class_name", null: false
    t.integer "priority", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "priority"
    t.integer "attempts"
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "disposition_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 2, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "documents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "documentable_id", null: false
    t.string "documentable_type", limit: 64, null: false
    t.string "document", limit: 128, null: false
    t.string "description", limit: 254, null: false
    t.string "original_filename", limit: 128, null: false
    t.string "content_type", limit: 128, null: false
    t.integer "file_size", null: false
    t.integer "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["documentable_id", "documentable_type"], name: "documents_idx2"
    t.index ["object_key"], name: "documents_idx1"
  end

  create_table "dual_fuel_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "primary_fuel_type_id"
    t.integer "secondary_fuel_type_id"
    t.boolean "active"
    t.index ["primary_fuel_type_id"], name: "index_dual_fuel_types_on_primary_fuel_type_id"
    t.index ["secondary_fuel_type_id"], name: "index_dual_fuel_types_on_secondary_fuel_type_id"
  end

  create_table "file_content_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "builder_name"
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["class_name"], name: "file_content_types_idx2"
    t.index ["name"], name: "file_content_types_idx1"
  end

  create_table "file_status_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["name"], name: "file_status_types_idx1"
  end

  create_table "forms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "roles", limit: 128, null: false
    t.string "controller", limit: 64, null: false
    t.integer "sort_order"
    t.boolean "active", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["object_key"], name: "forms_idx1"
  end

  create_table "frequency_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "fuel_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "description", null: false
    t.boolean "active", null: false
  end

  create_table "images", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "imagable_id", null: false
    t.string "imagable_type", limit: 64, null: false
    t.string "image", limit: 128, null: false
    t.string "description", limit: 254, null: false
    t.string "original_filename", limit: 128, null: false
    t.string "content_type", limit: 128, null: false
    t.integer "file_size", null: false
    t.integer "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["imagable_id", "imagable_type"], name: "images_idx2"
    t.index ["object_key"], name: "images_idx1"
  end

  create_table "issue_status_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active"
  end

  create_table "issue_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "issues", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "issue_type_id", null: false
    t.integer "web_browser_type_id", null: false
    t.integer "created_by_id", null: false
    t.text "comments", null: false
    t.integer "issue_status_type_id", default: 1
    t.text "resolution_comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["issue_type_id"], name: "issues_idx2"
    t.index ["object_key"], name: "issues_idx1"
  end

  create_table "keyword_search_indices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_class", limit: 64, null: false
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.string "context", limit: 64, null: false
    t.string "summary", limit: 64, null: false
    t.text "search_text", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["object_class"], name: "keyword_search_indices_idx1"
  end

  create_table "license_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "asset_manager", null: false
    t.boolean "web_services", null: false
    t.boolean "active", null: false
  end

  create_table "maintenance_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "manufacturer_models", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "organization_id"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_manufacturer_models_on_organization_id"
  end

  create_table "manufacturers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "filter", limit: 32, null: false
    t.string "name", limit: 128, null: false
    t.string "code", limit: 3, null: false
    t.boolean "active", null: false
    t.index ["filter"], name: "manufacturers_idx1"
  end

  create_table "message_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "message_id"
    t.integer "user_id"
    t.index ["message_id"], name: "message_tags_idx1"
    t.index ["user_id"], name: "message_tags_idx2"
  end

  create_table "messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.integer "user_id", null: false
    t.integer "to_user_id"
    t.integer "priority_type_id", null: false
    t.integer "thread_message_id"
    t.string "subject", limit: 64, null: false
    t.text "body"
    t.boolean "active"
    t.datetime "opened_at"
    t.datetime "created_at", null: false
    t.index ["object_key"], name: "messages_idx1"
    t.index ["organization_id"], name: "messages_idx2"
    t.index ["thread_message_id"], name: "messages_idx5"
    t.index ["to_user_id"], name: "messages_idx4"
    t.index ["user_id"], name: "messages_idx3"
  end

  create_table "notice_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "display_icon", limit: 64, null: false
    t.string "display_class", limit: 64, null: false
    t.boolean "active"
  end

  create_table "notices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.string "subject", limit: 64, null: false
    t.string "summary", limit: 128, null: false
    t.text "details"
    t.integer "notice_type_id"
    t.integer "organization_id"
    t.datetime "display_datetime"
    t.datetime "end_datetime"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.string "text", null: false
    t.string "link", null: false
    t.integer "notifiable_id"
    t.string "notifiable_type"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["notifiable_id", "notifiable_type"], name: "index_notifications_on_notifiable_id_and_notifiable_type"
  end

  create_table "organization_role_mappings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "role_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "display_icon_name", limit: 64, null: false
    t.string "map_icon_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "roles"
    t.boolean "active", null: false
    t.index ["class_name"], name: "organization_types_idx1"
  end

  create_table "organizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_type_id", null: false
    t.integer "customer_id", null: false
    t.string "external_id", limit: 32
    t.string "name", limit: 128, null: false
    t.string "short_name", limit: 16, null: false
    t.boolean "license_holder", null: false
    t.string "address1", limit: 128, null: false
    t.string "address2", limit: 128
    t.string "county", limit: 64
    t.string "city", limit: 64, null: false
    t.string "state", limit: 2, null: false
    t.string "zip", limit: 10, null: false
    t.string "phone", limit: 12, null: false
    t.string "phone_ext", limit: 6
    t.string "fax", limit: 10
    t.string "url", limit: 128, null: false
    t.boolean "indian_tribe"
    t.string "subrecipient_number", limit: 9
    t.string "ntd_id_number", limit: 4
    t.boolean "active", null: false
    t.decimal "latitude", precision: 11, scale: 6
    t.decimal "longitude", precision: 11, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "organizations_idx2"
    t.index ["organization_type_id"], name: "organizations_idx1"
    t.index ["short_name"], name: "organizations_idx4"
    t.index ["short_name"], name: "short_name"
  end

  create_table "organizations_saved_searches", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id"
    t.integer "saved_search_id"
    t.index ["organization_id"], name: "index_organizations_saved_searches_on_organization_id"
    t.index ["saved_search_id"], name: "index_organizations_saved_searches_on_saved_search_id"
  end

  create_table "policies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.integer "parent_id"
    t.integer "year", null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.integer "service_life_calculation_type_id", null: false
    t.integer "cost_calculation_type_id", null: false
    t.integer "condition_estimation_type_id", null: false
    t.decimal "condition_threshold", precision: 9, scale: 2, null: false
    t.decimal "interest_rate", precision: 9, scale: 2, null: false
    t.boolean "current", null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["object_key"], name: "policies_idx1"
    t.index ["organization_id"], name: "policies_idx2"
  end

  create_table "policy_asset_subtype_rules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "policy_id", null: false
    t.integer "asset_subtype_id", null: false
    t.integer "fuel_type_id"
    t.integer "min_service_life_months", null: false
    t.integer "min_service_life_miles"
    t.integer "replacement_cost", null: false
    t.integer "cost_fy_year", null: false
    t.boolean "replace_with_new", null: false
    t.boolean "replace_with_leased", null: false
    t.integer "replace_asset_subtype_id"
    t.integer "replace_fuel_type_id"
    t.integer "lease_length_months"
    t.integer "rehabilitation_service_month"
    t.integer "rehabilitation_labor_cost"
    t.integer "rehabilitation_parts_cost"
    t.integer "extended_service_life_months"
    t.integer "extended_service_life_miles"
    t.integer "min_used_purchase_service_life_months", null: false
    t.string "purchase_replacement_code", limit: 8, null: false
    t.string "lease_replacement_code", limit: 8
    t.string "purchase_expansion_code", limit: 8
    t.string "lease_expansion_code", limit: 8
    t.string "rehabilitation_code", limit: 8, null: false
    t.string "engineering_design_code", limit: 8
    t.string "construction_code", limit: 8
    t.boolean "default_rule"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["asset_subtype_id"], name: "policy_asset_subtype_rules_idx2"
    t.index ["policy_id"], name: "policy_asset_subtype_rules_idx1"
  end

  create_table "policy_asset_type_rules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "policy_id", null: false
    t.integer "asset_type_id", null: false
    t.integer "service_life_calculation_type_id", null: false
    t.integer "replacement_cost_calculation_type_id", null: false
    t.integer "condition_rollup_calculation_type_id"
    t.decimal "annual_inflation_rate", precision: 9, scale: 2, null: false
    t.integer "pcnt_residual_value", null: false
    t.integer "condition_rollup_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["asset_type_id"], name: "policy_asset_type_rules_idx2"
    t.index ["policy_id"], name: "policy_asset_type_rules_idx1"
  end

  create_table "priority_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "is_default", null: false
    t.boolean "active", null: false
  end

  create_table "query_params", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.text "query_string"
    t.string "class_name"
    t.boolean "active"
  end

  create_table "replacement_reason_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active"
  end

  create_table "replacement_status_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "active"
  end

  create_table "report_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "display_icon_name", limit: 64, null: false
    t.boolean "active", null: false
  end

  create_table "reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "report_type_id", null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "class_name", null: false
    t.string "view_name", limit: 32, null: false
    t.string "roles", limit: 128
    t.text "custom_sql"
    t.boolean "show_in_nav"
    t.boolean "show_in_dashboard"
    t.string "chart_type", limit: 32
    t.text "chart_options"
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_type_id"], name: "reports_idx1"
  end

  create_table "roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.integer "weight"
    t.integer "resource_id"
    t.string "resource_type"
    t.integer "role_parent_id"
    t.boolean "show_in_user_mgmt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "privilege", default: false, null: false
    t.string "label"
    t.index ["name"], name: "roles_idx1"
    t.index ["resource_id"], name: "roles_idx2"
  end

  create_table "rule_sets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key"
    t.string "name"
    t.string "class_name"
    t.boolean "rule_set_aware"
    t.boolean "active"
  end

  create_table "saved_searches", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "user_id", null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.integer "search_type_id"
    t.text "json"
    t.text "query_string"
    t.integer "ordinal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "class_name"
    t.boolean "active"
  end

  create_table "serial_numbers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "identifiable_type"
    t.bigint "identifiable_id"
    t.string "identification"
    t.index ["identifiable_type", "identifiable_id"], name: "index_serial_numbers_on_identifiable_type_and_identifiable_id"
  end

  create_table "service_life_calculation_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["class_name"], name: "service_life_calculation_types_idx1"
  end

  create_table "service_status_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 1, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "system_config_extensions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "class_name"
    t.string "extension_name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "system_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "customer_id"
    t.string "start_of_fiscal_year", limit: 5
    t.string "default_fiscal_year_formatter"
    t.string "default_weather_code"
    t.string "map_tile_provider", limit: 64
    t.integer "srid"
    t.float "min_lat"
    t.float "min_lon"
    t.float "max_lat"
    t.float "max_lon"
    t.integer "search_radius"
    t.string "search_units", limit: 8
    t.string "geocoder_components", limit: 128
    t.string "geocoder_region", limit: 64
    t.integer "num_forecasting_years"
    t.integer "num_reporting_years"
    t.integer "max_rows_returned"
    t.string "special_locked_fields"
    t.string "measurement_system"
    t.string "data_file_path", limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "taskable_id"
    t.string "taskable_type"
    t.integer "user_id", null: false
    t.integer "priority_type_id", null: false
    t.integer "organization_id", null: false
    t.integer "assigned_to_user_id"
    t.string "subject", limit: 64, null: false
    t.text "body", null: false
    t.boolean "send_reminder"
    t.string "state", limit: 32
    t.datetime "complete_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_user_id"], name: "tasks_idx5"
    t.index ["complete_by"], name: "tasks_idx6"
    t.index ["object_key"], name: "tasks_idx1"
    t.index ["organization_id"], name: "tasks_idx4"
    t.index ["state"], name: "tasks_idx3"
    t.index ["user_id"], name: "tasks_idx2"
  end

  create_table "transam_assets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "transam_assetible_type"
    t.bigint "transam_assetible_id"
    t.string "object_key", limit: 12, null: false
    t.bigint "organization_id", null: false
    t.bigint "asset_subtype_id"
    t.bigint "upload_id"
    t.string "asset_tag", null: false
    t.date "disposition_date"
    t.string "external_id"
    t.text "description"
    t.bigint "manufacturer_id"
    t.string "other_manufacturer"
    t.bigint "manufacturer_model_id"
    t.string "other_manufacturer_model"
    t.integer "manufacture_year"
    t.integer "quantity"
    t.string "quantity_unit"
    t.integer "purchase_cost"
    t.date "purchase_date"
    t.boolean "purchased_new"
    t.date "in_service_date"
    t.bigint "vendor_id"
    t.string "other_vendor"
    t.bigint "operator_id"
    t.string "other_operator"
    t.string "title_number"
    t.bigint "title_ownership_organization_id"
    t.string "other_title_ownership_organization"
    t.bigint "lienholder_id"
    t.string "other_lienholder"
    t.integer "parent_id"
    t.integer "location_id"
    t.integer "policy_replacement_year"
    t.integer "scheduled_replacement_year"
    t.integer "scheduled_replacement_cost"
    t.text "early_replacement_reason"
    t.boolean "in_backlog"
    t.integer "scheduled_rehabilitation_year"
    t.integer "scheduled_disposition_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_subtype_id"], name: "index_transam_assets_on_asset_subtype_id"
    t.index ["lienholder_id"], name: "index_transam_assets_on_lienholder_id"
    t.index ["manufacturer_id"], name: "index_transam_assets_on_manufacturer_id"
    t.index ["manufacturer_model_id"], name: "index_transam_assets_on_manufacturer_model_id"
    t.index ["operator_id"], name: "index_transam_assets_on_operator_id"
    t.index ["organization_id"], name: "index_transam_assets_on_organization_id"
    t.index ["title_ownership_organization_id"], name: "index_transam_assets_on_title_ownership_organization_id"
    t.index ["transam_assetible_type", "transam_assetible_id"], name: "transam_assetible_idx"
    t.index ["upload_id"], name: "index_transam_assets_on_upload_id"
    t.index ["vendor_id"], name: "index_transam_assets_on_vendor_id"
  end

  create_table "uploads", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id"
    t.integer "user_id", null: false
    t.integer "file_content_type_id", null: false
    t.integer "file_status_type_id", null: false
    t.string "file", limit: 128, null: false
    t.string "original_filename", limit: 254, null: false
    t.integer "num_rows_processed"
    t.integer "num_rows_added"
    t.integer "num_rows_replaced"
    t.integer "num_rows_skipped"
    t.integer "num_rows_failed"
    t.text "processing_log", limit: 4294967295
    t.boolean "force_update"
    t.datetime "processing_started_at"
    t.datetime "processing_completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["file_content_type_id"], name: "uploads_idx4"
    t.index ["file_status_type_id"], name: "uploads_idx5"
    t.index ["object_key"], name: "uploads_idx1"
    t.index ["organization_id"], name: "uploads_idx2"
    t.index ["user_id"], name: "uploads_idx3"
  end

  create_table "user_notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "notification_id", null: false
    t.datetime "opened_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["notification_id"], name: "index_user_notifications_on_notification_id"
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
  end

  create_table "user_organization_filters", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sort_order"
    t.integer "created_by_user_id"
    t.text "query_string"
    t.integer "resource_id"
    t.string "resource_type"
    t.index ["created_by_user_id"], name: "index_user_organization_filters_on_created_by_user_id"
    t.index ["object_key"], name: "user_organization_filters_idx1"
  end

  create_table "user_organization_filters_organizations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_organization_filter_id", null: false
    t.integer "organization_id", null: false
    t.index ["user_organization_filter_id", "organization_id"], name: "user_organization_filters_idx1"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.string "external_id", limit: 32
    t.string "first_name", limit: 64, null: false
    t.string "last_name", limit: 64, null: false
    t.string "title", limit: 64
    t.string "phone", limit: 12, null: false
    t.string "phone_ext", limit: 6
    t.string "timezone", limit: 32, null: false
    t.string "email", limit: 128, null: false
    t.string "address1", limit: 64
    t.string "address2", limit: 64
    t.string "city", limit: 32
    t.string "state", limit: 2
    t.string "zip", limit: 10
    t.integer "num_table_rows"
    t.integer "user_organization_filter_id"
    t.string "encrypted_password", limit: 64, null: false
    t.string "reset_password_token", limit: 64
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 16
    t.string "last_sign_in_ip", limit: 16
    t.integer "failed_attempts", null: false
    t.string "unlock_token", limit: 128
    t.datetime "locked_at"
    t.boolean "notify_via_email", null: false
    t.integer "weather_code_id"
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "users_idx3"
    t.index ["object_key"], name: "users_idx1"
    t.index ["organization_id"], name: "users_idx2"
  end

  create_table "users_organizations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.index ["user_id", "organization_id"], name: "users_organizations_idx2"
  end

  create_table "users_roles", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.integer "granted_by_user_id"
    t.date "granted_on_date"
    t.integer "revoked_by_user_id"
    t.date "revoked_on_date"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["active"], name: "users_roles_idx3"
    t.index ["user_id", "role_id"], name: "users_roles_idx2"
  end

  create_table "users_user_organization_filters", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "user_organization_filter_id", null: false
    t.index ["user_id"], name: "users_user_organization_filters_idx1"
    t.index ["user_organization_filter_id"], name: "users_user_organization_filters_idx2"
  end

  create_table "users_viewable_organizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
  end

  create_table "vendors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.string "name", limit: 64, null: false
    t.string "address1", limit: 64
    t.string "address2", limit: 64
    t.string "city", limit: 64
    t.string "state", limit: 2
    t.string "zip", limit: 10
    t.string "phone", limit: 12
    t.string "phone_ext", limit: 6
    t.string "fax", limit: 12
    t.string "url", limit: 128
    t.decimal "latitude", precision: 11, scale: 6
    t.decimal "longitude", precision: 11, scale: 6
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "vendors_idx2"
    t.index ["object_key"], name: "vendors_idx1"
    t.index ["organization_id"], name: "vendors_idx3"
  end

  create_table "versions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
  end

  create_table "weather_codes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "state", limit: 2
    t.string "code", limit: 8
    t.string "city", limit: 64
    t.boolean "active"
    t.index ["state", "city"], name: "weather_codes_idx"
  end

  create_table "web_browser_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "workflow_events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "accountable_id", null: false
    t.string "accountable_type", limit: 64, null: false
    t.string "event_type", limit: 64, null: false
    t.integer "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["accountable_id", "accountable_type"], name: "workflow_events_idx2"
    t.index ["object_key"], name: "workflow_events_idx1"
  end

end
