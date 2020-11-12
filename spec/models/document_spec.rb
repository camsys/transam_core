require 'rails_helper'

RSpec.describe Document, :type => :model do

  let(:test_doc) { create(:document, :documentable => create(:buslike_asset)) }

  describe 'associations' do
    it 'has a creator' do
      expect(test_doc).to belong_to(:creator)
    end
  end
  describe 'validations' do
    it 'is not required to have a description' do
      test_doc.description = nil
      expect(test_doc.valid?).to be true
    end
    it 'must have an original filename' do
      test_doc.original_filename = nil
      expect(test_doc.valid?).to be false
    end
    it 'must have a document' do
      test_doc = build_stubbed(:document, :documentable => create(:buslike_asset), :document => nil)
      expect(test_doc.valid?).to be false
    end
    it 'must have a creator' do
      test_doc.creator =  nil
      expect(test_doc.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(Document.allowable_params).to eq([
      :documentable_id,
      :documentable_type,
      :document,
      :description,
      :original_filename,
      :content_type,
      :file_size,
      :created_by_id
    ])
  end

  it '.to_s' do
    expect(test_doc.to_s).to eq(test_doc.name)
    expect(test_doc.to_s).to eq(test_doc.original_filename)
  end
  it '.name' do
    expect(test_doc.name).to eq(test_doc.original_filename)
  end
  it '.searchable_fields' do
    expect(test_doc.searchable_fields).to eq([
      :object_key,
      :description,
      :original_filename,
      :content_type
    ])
  end

  describe '.organization' do
    it 'documentable does not have org' do
      test_doc.documentable = create(:asset_event)

      expect(test_doc.organization).to eq(test_doc.creator.organization)
    end
    it 'documentable has org' do
      test_asset = create(:buslike_asset)
      test_doc.documentable = test_asset

      expect(test_doc.organization).to eq(test_asset.organization)
    end
  end
end
