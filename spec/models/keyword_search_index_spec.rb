require 'rails_helper'

RSpec.describe KeywordSearchIndex, :type => :model do

  let(:test_asset) { create(:equipment_asset) }
  let(:test_search) { create(:keyword_search_index, :object_key => test_asset.object_key, :object_class => 'Inventory', :search_text => test_asset.description) }

  describe 'associations' do
    it 'must have an org' do
      expect(test_search).to belong_to(:organization)
    end
  end

  describe 'validations' do
    it 'must have an object key' do
      test_search.object_key = nil
      expect(test_search.valid?).to be false
    end
    it 'must have an object class' do
      test_search.object_class = nil
      expect(test_search.valid?).to be false
    end
    it 'must have a search text' do
      test_search.search_text = nil
      expect(test_search.valid?).to be false
    end
  end

  it '.to_s' do
    expect(test_search.to_s).to eq(test_search.name)
  end
  it '.name' do
    expect(test_search.name).to eq("#{test_search.object_class.underscore}_path(:id => '#{test_search.object_key}')")
  end
end
