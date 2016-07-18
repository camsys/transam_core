require 'rails_helper'

RSpec.describe Task, :type => :model do

  let(:test_task) { create(:task) }

  it 'associations' do
    expect(test_task).to belong_to(:taskable)
    expect(test_task).to belong_to(:user)
    expect(test_task).to belong_to(:organization)
    expect(test_task).to belong_to(:assigned_to_user)
    expect(test_task).to belong_to(:priority_type)
  end

  describe 'validations' do
    it 'must have a user' do
      test_task.user = nil

      expect(test_task.valid?).to be false
    end
    it 'must have a priority type' do
      test_task.priority_type = nil

      expect(test_task.valid?).to be false
    end
    it 'must have an org' do
      test_task.organization = nil

      expect(test_task.valid?).to be false
    end
    it 'must have a subject' do
      test_task.subject = nil

      expect(test_task.valid?).to be false
    end
    it 'must have a body' do
      test_task.body = nil

      expect(test_task.valid?).to be false
    end
    it 'must have a completion date' do
      test_task.complete_by = nil

      expect(test_task.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(Task.allowable_params).to eq([
      :user_id,
      :organization_id,
      :priority_type_id,
      :assigned_to_user_id,
      :subject,
      :state,
      :body,
      :send_reminder,
      :complete_by
    ])
  end
  it '#active_states' do
    expect(Task.active_states).to eq(["new", "started", "halted"])
  end
  it '#terminal_states' do
    expect(Task.terminal_states).to eq(["cancelled", "completed"])
  end

  it '.name' do
    expect(test_task.name).to eq(test_task.subject)
  end
  it '.set_defaults' do
    expect(test_task.state).to eq('new')
    expect(test_task.send_reminder).to be true
    expect(test_task.complete_by.to_date).to eq(Date.today + 1.week)
  end
end
