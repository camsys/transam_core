require 'spec_helper'

RSpec.describe AssetSearcher do
  let(:bus) { create(:bus) }
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  it 'should be able to search by manufacturer' do
    searcher = AssetSearcher.new(:manufacturer_ids => [bus.id], :organization_id => bus.organization )
    expect(searcher.data).to eq(Asset.where('manufacturer_id = ?', [bus.id]))
  end
end
