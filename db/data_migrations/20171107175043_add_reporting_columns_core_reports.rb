class AddReportingColumnsCoreReports < ActiveRecord::DataMigration
  def up
    Report.find_by(name: 'User Login Report').update!(printable: true, exportable: true) if Report.find_by(name: 'User Login Report')
    Report.find_by(name: 'Issues Report').update!(printable: true, exportable: true) if Report.find_by(name: 'Issues Report')
  end
end