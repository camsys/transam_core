class AddUserRolesToReports < ActiveRecord::Migration
  def change
    # Add a string column contianing a comma-delimited list of roles that are allowed
    # to view the report
    add_column    :reports, :roles, :string, :limit => 128, :after => :view_name
  end
end
