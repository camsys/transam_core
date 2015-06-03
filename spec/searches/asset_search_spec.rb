require 'rails_helper'

RSpec.describe AssetSearch, :type => :model do

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  it 'should be able to search by in service date' do
    searcher = AssetSearcher.new();
    expect(searcher.attributes).to include(:in_service_date)
    expect(searcher.attributes).to include(:in_service_date_comparator)

    searcher = AssetSearcher.new(:in_service_date => 2014, :in_service_date_comparator => '0')
    expect(searcher.data). to eq(Asset.where(‘organization_id = 1’))
  end
end
