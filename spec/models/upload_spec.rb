require 'rails_helper'

RSpec.describe Upload, :type => :model do

  let(:test_upload) { create(:upload) }

  describe 'associations' do
    it 'has a user' do
      expect(test_upload).to belong_to(:user)
    end
    it 'has an org' do
      expect(test_upload).to belong_to(:organization)
    end
    it 'has a file status type' do
      expect(test_upload).to belong_to(:file_status_type)
    end
    it 'has a file content type' do
      expect(test_upload).to belong_to(:file_content_type)
    end
    it 'has many asset events' do
      expect(test_upload).to have_many(:asset_events)
    end
  end

  describe 'validations' do
    it 'must have an org' do
      test_upload.organization = nil
      expect(test_upload.valid?).to be false
    end
    it 'must have a user' do
      test_upload.user = nil
      expect(test_upload.valid?).to be false
    end
    it 'must have a file status' do
      test_upload.file_status_type = nil
      expect(test_upload.valid?).to be false
    end
    it 'must have a file content' do
      test_upload.file_content_type = nil
      expect(test_upload.valid?).to be false
    end
    it 'must have a file' do
      test_upload = build_stubbed(:upload, :file=> nil)
      expect(test_upload.valid?).to be false
    end
    it 'must have a file name' do
      test_upload.original_filename = nil
      expect(test_upload.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(Upload.allowable_params).to eq([
      :organization_id,
      :user_id,
      :file_status_type_id,
      :file_content_type_id,
      :file,
      :original_filename,
      :force_update,
      :num_rows_processed,
      :num_rows_added,
      :num_rows_replaced,
      :num_rows_failed,
      :processing_log,
      :processing_completed_at,
      :processing_started_at
    ])
  end

  describe '.processing_time' do
    it 'not started' do
      expect(Upload.new.processing_time).to be nil
    end
    it 'started not finished' do
      test_upload.processing_started_at = Time.now
      test_upload.processing_completed_at = nil
      expect(test_upload.processing_time).to be nil
    end
    it 'started and finished' do
      test_upload.processing_started_at = Time.now - 10.minutes
      test_upload.processing_completed_at = Time.now
      expect(test_upload.processing_time).to eq(test_upload.processing_completed_at - test_upload.processing_started_at)
    end
  end
  describe '.can_resubmit?' do
    it 'new record' do
      expect(Upload.new.can_resubmit?).to be false
    end
    it 'file status type that cant delete' do
      expect(test_upload.can_resubmit?).to be false
    end
    it 'file status type that can delete' do
      test_upload.file_status_type_id = 3
      expect(test_upload.can_resubmit?).to be true
    end
  end
  describe '.can_delete?' do
    it 'new record' do
      expect(Upload.new.can_delete?).to be false
    end
    it 'file status type that cant delete' do
      expect(test_upload.can_delete?).to be false
    end
    it 'file status type that can delete' do
      test_upload.file_status_type_id = 3
      expect(test_upload.can_delete?).to be true
    end
  end
  it '.reset' do
    test_upload.file_status_type = FileStatusType.find_by_name('In Progress')
    test_upload.num_rows_processed = 1
    test_upload.num_rows_added = 1
    test_upload.num_rows_replaced = 1
    test_upload.num_rows_failed = 1
    test_upload.num_rows_skipped = 1
    test_upload.processing_log = 1
    test_upload.processing_completed_at = 1
    test_upload.processing_started_at = 1
    expect(test_upload.num_rows_processed).not_to be nil
    expect(test_upload.num_rows_added).not_to be nil
    expect(test_upload.num_rows_replaced).not_to be nil
    expect(test_upload.num_rows_failed).not_to be nil
    expect(test_upload.num_rows_skipped).not_to be nil
    expect(test_upload.processing_log).not_to be nil
    test_upload.reset
    expect(test_upload.num_rows_processed).to be nil
    expect(test_upload.num_rows_added).to be nil
    expect(test_upload.num_rows_replaced).to be nil
    expect(test_upload.num_rows_failed).to be nil
    expect(test_upload.num_rows_skipped).to be nil
    expect(test_upload.processing_log).to be nil
    expect(test_upload.file_status_type).to eq(FileStatusType.find_by_name('Unprocessed'))

  end

  it '.set_defaults' do
    expect(Upload.new.file_status_type).to eq(FileStatusType.find_by_name('Unprocessed'))
  end
end
