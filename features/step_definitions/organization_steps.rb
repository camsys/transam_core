#### MOCK CLASSES #####
module TransamMapMarkers; end

def create_organization
  @organization = FactoryBot.create(:organization)
  @policy = FactoryBot.create(:policy, :organization => @organization)

  return @organization
end
