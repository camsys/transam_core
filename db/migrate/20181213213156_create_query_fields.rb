class CreateQueryFields < ActiveRecord::Migration[5.2]
  def change
    create_table :query_fields do |t|

      t.timestamps
    end
  end
end
