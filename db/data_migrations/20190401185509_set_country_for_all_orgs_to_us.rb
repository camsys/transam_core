class SetCountryForAllOrgsToUs < ActiveRecord::DataMigration
  def up
    Organization.update_all country: "US"
  end

  def down

  end
end