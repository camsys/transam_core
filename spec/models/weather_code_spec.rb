require 'rails_helper'

RSpec.describe WeatherCode, :type => :model do
  let(:test_code) { create(:weather_code) }

  before(:each) do
    WeatherCode.destroy_all
  end

  it 'default_scope' do
    test_code.update!(:active => false)

    expect(WeatherCode.active.count).to eq(0)
  end

  it 'ordered by city' do
    test_code.update!(:city => "Brooklyn")
    create(:weather_code).update!(:city => "Amsterdam")

    expect(WeatherCode.all.map{|wc| wc.city}).to eq(["Amsterdam", "Brooklyn"])
  end

  it '.to_s' do
    expect(test_code.to_s).to eq("Temp")
  end

  it '#search' do
    test_code.save! # initialize
    expect(WeatherCode.search("MA","Temp")).to eq(test_code)
  end
end
