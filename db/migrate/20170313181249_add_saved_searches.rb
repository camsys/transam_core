class AddSavedSearches < ActiveRecord::Migration
  def change
    create_table "saved_searches", force: true do |t|
      t.string   "object_key",        limit: 12,  null: false
      t.integer  "user_id",                       null: false
      t.string   "name",              limit: 64,  null: false
      t.string   "description",       limit: 254, null: false
      t.integer   "search_type_id"
      t.text     "json"
      t.text     "query_string"
      t.integer  "ordinal"

      t.timestamps

    end
  end
end
