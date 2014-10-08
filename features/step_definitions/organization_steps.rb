def create_organization(org_name, org_short_name)
  @organization = FactoryGirl.create(:organization, {:name => org_name, :short_name => org_short_name})
end