require 'rails_helper'

RSpec.describe Issue, :type => :model do

  let(:test_issue) { create(:issue) }

  describe 'associations' do
    it 'must have a creator' do
      expect(test_issue).to belong_to(:creator)
    end
    it 'has a type' do
      expect(test_issue).to belong_to(:issue_type)
    end
    it 'has a web browser type' do
      expect(test_issue).to belong_to(:web_browser_type)
    end
  end

  describe 'validations' do
    it 'must have a type' do
      test_issue.issue_type = nil
      expect(test_issue.valid?).to be false
    end
    it 'must have a web browser type' do
      test_issue.web_browser_type = nil
      expect(test_issue.valid?).to be false
    end
    it 'must have comments' do
      test_issue.comments = nil
      expect(test_issue.valid?).to be false
    end
    it 'must have a creator' do
      test_issue.creator = nil
      expect(test_issue.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(Issue.allowable_params).to eq([
      :issue_type_id,
      :web_browser_type_id,
      :comments,
      :issue_status_type_id,
      :resolution_comments
    ])
  end
end
