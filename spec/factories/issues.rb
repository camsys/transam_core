FactoryBot.define do

  factory :issue do
    issue_type_id 1
    web_browser_type_id 1
    comments 'test issue comment'
    association :creator, :factory => :normal_user
  end
end
