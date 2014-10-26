RSpec.configure do |config|
  # additional factory_girl configuration
  config.before(:suite) do
    begin
      #FactoryGirl.lint
    ensure
    end
  end
end
