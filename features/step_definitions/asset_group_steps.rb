Given(/^an \[asset_group\] exists$/) do
  FactoryBot.create(:asset_group, :name => "Test Group 1", :code => "TG1", :organization => Organization.last)
end
