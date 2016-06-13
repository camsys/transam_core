class AddResolutionColumnsToIssue < ActiveRecord::Migration
  def change

    unless ActiveRecord::Base.connection.table_exists? 'issue_status_types'
      create_table :issue_status_types, :force => true do |t|
        t.string  :name,        :limit => 32,   :null => false
        t.string  :description, :limit => 254,  :null => false
        t.boolean  "active"
      end
    end

    unless column_exists? :issues, :issue_status
      add_column    :issues, :issue_status, :string, :after => :comments
    end
    unless column_exists? :issues, :resolution_comments
      add_column    :issues, :resolution_comments, :text, :after => :issue_status
    end

  end
end