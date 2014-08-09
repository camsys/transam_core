class AddIssuesTable < ActiveRecord::Migration
  def change
    
    # Issue Type Lookup Table
    create_table :issue_types do |t|
      t.string    :name,                :limit => 64, :null => :false
      t.string    :description,                       :null => :false
      t.boolean   :active,                            :null => :false
    end

    # Browser Type Lookup Table
    create_table :web_browser_types do |t|
      t.string    :name,                :limit => 64, :null => :false
      t.string    :description,                       :null => :false
      t.boolean   :active,                            :null => :false
    end
    
    # Issues Reporting table
    create_table :issues do |t|
      t.string    :object_key,        :limit => 12,   :null => :false
      t.integer   :issue_type_id,                     :null => :false
      t.integer   :web_browser_type_id,               :null => :false
      t.integer   :created_by_id,                     :null => :false      
      t.text      :comments,                          :null => :false
      t.timestamps
    end
    add_index :issues, [:object_key],     :name => "issues_idx1"
    add_index :issues, [:issue_type_id],  :name => "issues_idx2"
  end
end
