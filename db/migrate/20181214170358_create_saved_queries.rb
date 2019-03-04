class CreateSavedQueries < ActiveRecord::Migration[5.2]
  def change
    create_table :saved_queries do |t|
      t.string "object_key"
      t.string "name"
      t.string "description"
      t.integer "created_by_user_id"
      t.integer "updated_by_user_id"
      t.integer "shared_from_org_id"
      t.datetime "created_at"
      t.datetime "updated_at"

      t.timestamps
    end
  end
end
