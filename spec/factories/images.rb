FactoryBot.define do
  factory :image do
    association :creator, factory: :normal_user
    original_filename 'test_pic.png'
    description 'Test Image'
    image { Rack::Test::UploadedFile.new(File.join(TransamCore::Engine.root, 'spec', 'support', 'test_files', 'test_pic.png'), 'image/png') }
    imagable_type 'Asset'
  end
end
