FactoryBot.define do
  factory :upload do
    association :organization
    association :user, factory: :normal_user
    file_content_type_id 1
    file { Rack::Test::UploadedFile.new(File.join(TransamCore::Engine.root, 'spec', 'support', 'test_files', 'test_spreadsheet.xlsx')) }
    original_filename 'test_spreadsheet.xlsx'
  end
end
