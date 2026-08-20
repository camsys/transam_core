class IncreaseNoticeSummaryLimitToTwoHundredFiftyFour < ActiveRecord::Migration[5.2]
  def up
    change_column :notices, :summary, :string, limit: 254
  end

  def down
    change_column :notices, :summary, :string, limit: 128
  end
end
