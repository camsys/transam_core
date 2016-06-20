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

    issue_report = Report.find_by(id: 2)
    issue_report.view_name = 'issues_report_table'
    issue_report.custom_sql = "SELECT d.short_name AS 'ORGANIZATION', b.name AS 'TYPE', a.created_at AS 'DATE/TIME', a.comments AS 'COMMENTS', e.name AS 'BROWSER TYPE', c.first_name AS 'FIRST NAME', c.last_name AS 'LAST NAME', c.phone AS 'PHONE', f.name AS 'ISSUE_STATUS' , a.resolution_comments AS 'RESOLUTION_COMMENTS', a.object_key AS 'ISSUE ID' FROM issues a LEFT JOIN issue_types b ON a.issue_type_id=b.id LEFT JOIN users c ON a.created_by_id=c.id LEFT JOIN organizations d ON c.organization_id=d.id LEFT JOIN web_browser_types e ON a.web_browser_type_id=e.id LEFT JOIN issue_status_types f ON a.issue_status_type_id=f.id WHERE a.issue_status_type_id != 2 ORDER BY a.created_at"
    issue_report.save

  end
end
