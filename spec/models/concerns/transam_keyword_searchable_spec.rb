require 'rails_helper'

RSpec.describe TransamKeywordSearchable do

  # No legacy counterpart - added from the TTPLAT-3072 coverage screen.
  # build_index_object has no callers anywhere in app/ or lib/ - it is dead
  # code today, not merely uncovered, but it is directly callable (unlike
  # get_typed_asset's unreachable branch) so it is tested as written.
  describe '#build_index_object' do
    it 'builds an unsaved KeywordSearchIndex populated from the asset' do
      test_asset = create(:buslike_asset, :description => 'A description for searching')

      index = test_asset.build_index_object

      expect(index).to be_a(KeywordSearchIndex)
      expect(index).to be_new_record
      expect(index.object_key).to eq(test_asset.object_key)
      expect(index.organization_id).to eq(test_asset.organization_id)
      expect(index.context).to eq('TransamAsset')
      expect(index.object_class).to eq('TransamAsset')
      expect(index.summary).to eq('A description for searching')
      expect(index.search_text).to include(test_asset.asset_tag)
    end
  end
end
