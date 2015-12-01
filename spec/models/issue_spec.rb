require 'rails_helper'

RSpec.describe Issue, :type => :model do

  let(:test_issue) { create(:issue) }

  describe 'associations' do
    it 'must have a creator' do
      expect(Issue.column_names).to include('created_by_id')
    end
    it 'has a type' do
      expect(Issue.column_names).to include('issue_type_id')
    end
    it 'has a web browser type' do
      expect(Issue.column_names).to include('web_browser_type_id')
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
      :comments
    ])
  end
end
