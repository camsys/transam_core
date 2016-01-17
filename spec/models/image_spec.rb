require 'rails_helper'

RSpec.describe Image, :type => :model do

  let(:test_image) { create(:image, :imagable => create(:buslike_asset)) }

  describe 'associations' do
    it 'belongs to something' do
      expect(test_image).to belong_to(:imagable)
    end
    it 'has a creator' do
      expect(test_image).to belong_to(:creator)
    end
  end

  describe 'validations' do
    it 'must has a description' do
      test_image.description = nil
      expect(test_image.valid?).to be false
    end
    it 'must have a filename' do
      test_image.original_filename = nil
      expect(test_image.valid?).to be false
    end
    it 'must have an image' do
      test_image = build_stubbed(:image, :imagable => create(:buslike_asset), :image => nil)
      expect(test_image.valid?).to be false
    end
    it 'must have a creator' do
      test_image.creator = nil
      expect(test_image.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(Image.allowable_params).to eq([
      :imagable_id,
      :imagable_type,
      :image,
      :description,
      :original_filename,
      :content_type,
      :file_size,
      :created_by_id
    ])
  end

  it '.to_s' do
    expect(test_image.to_s).to eq(test_image.name)
    expect(test_image.to_s).to eq(test_image.original_filename)
  end
  it '.name' do
    expect(test_image.name).to eq(test_image.original_filename)
  end
  it '.searchable_fields' do
    expect(test_image.searchable_fields).to eq([
      :object_key,
      :original_filename,
      :description,
      :content_type
    ])
  end
  describe '.organization' do
    it 'imagable org' do
      expect(test_image.organization).to eq(test_image.imagable.organization)
    end
    it 'creator org' do
      test_image.update!(:imagable => create(:asset_event))
      puts test_image.imagable.respond_to? :organization
      expect(test_image.organization).to eq(test_image.creator.organization)
    end
  end

  it '.update_file_attributes' do
    expect(test_image.content_type).to eq('image/png')
    expect(test_image.file_size).to be > 0
  end
end
