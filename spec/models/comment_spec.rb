require 'rails_helper'

RSpec.describe Comment, :type => :model do
  let(:test_comment) { create(:comment, :commentable => create(:buslike_asset)) }

  describe 'associations' do
    it 'has a creator' do
      expect(Comment.column_names).to include('created_by_id')
    end
  end

  describe 'validations' do
    it 'must have a commment' do
      test_comment.comment = nil
      expect(test_comment.valid?).to be false
    end
    it 'must have a creator' do
      test_comment.creator = nil

      expect(test_comment.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(Comment.allowable_params).to eq([
      :comment,
      :commentable_id,
      :commentable_type,
      :created_by_id
    ])
  end

  it '.searchable_fields' do
    expect(test_comment.searchable_fields).to eq([
      :object_key,
      :comment
    ])
  end

  it '.to_s' do
    expect(test_comment.to_s).to eq(test_comment.comment)
  end
  it '.description' do
    expect(test_comment.description).to eq(test_comment.comment)
  end

  describe '.organization' do
    it 'commentable does not have org' do
      test_comment.commentable = create(:asset_event)

      expect(test_comment.organization).to eq(test_comment.creator.organization)
    end
    it 'commentable has org' do
      test_asset = create(:buslike_asset)
      test_comment.commentable = test_asset

      expect(test_comment.organization).to eq(test_asset.organization)
    end
  end
end
