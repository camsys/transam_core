FactoryBot.define do
  factory :document do
    association :creator, factory: :normal_user
    original_filename 'test_doc.pdf'
    description 'Test Document'
    document { Rack::Test::UploadedFile.new(File.join(TransamCore::Engine.root, 'spec', 'support', 'test_files', 'test_doc.pdf')) }
    documentable_type 'Asset'
  end
end
