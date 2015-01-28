def create_organization
  @organization = FactoryGirl.create(:organization)
  @policy = FactoryGirl.create(:policy, :organization => @organization)

  return @organization
end
