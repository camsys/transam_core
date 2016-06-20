class AddResolutionColumnsToIssue < ActiveRecord::Migration
  def change

    unless ActiveRecord::Base.connection.table_exists? 'issue_status_types'
      create_table :issue_status_types, :force => true do |t|
        t.string  :name,        :limit => 32,   :null => false
        t.string  :description, :limit => 254,  :null => false
        t.boolean  "active"
      end
    end

    unless column_exists? :issues, :issue_status_type_id
      add_column    :issues, :issue_status_type_id, :integer, :after => :comments, :default => 1
    end
    unless column_exists? :issues, :resolution_comments
      add_column    :issues, :resolution_comments, :text, :after => :issue_status_type_id
    end

    unless Rails.env.test?
      reversible do |change|
        change.up do
          Rake::Task['transam_core_data:update_issue_report_with_new_custom_sql'].invoke
        end
      end
    end

  end
end
