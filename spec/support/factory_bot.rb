RSpec.configure do |config|
  # additional factory_girl configuration
  config.before(:suite) do
    begin
      #FactoryBot.lint
    ensure
    end
  end
end
