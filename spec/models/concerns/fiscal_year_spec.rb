require 'rails_helper'

RSpec.describe FiscalYear do
  class DummyClass
    include FiscalYear
  end

  let(:test_fy_class) { DummyClass.new }

  it '.start_of_fiscal_year' do
    expect(test_fy_class.start_of_fiscal_year(Date.today.year)).to eq(Date.new(Date.today.year,7,1))
  end
  it '.start_of_planning_year' do
    year = Date.today.month > 6 ? Date.today.year + 1 : Date.today.year
    expect(test_fy_class.start_of_planning_year).to eq(Date.new(year,7,1))
  end
  it '.fiscal_year_epoch_year' do
    expect(test_fy_class.fiscal_year_epoch_year).to eq(test_fy_class.fiscal_year_year_on_date(SystemConfig.instance.epoch))
  end
  it '.fiscal_year_epoch' do
    expect(test_fy_class.fiscal_year_epoch).to eq(test_fy_class.fiscal_year_on_date(SystemConfig.instance.epoch))
  end
  it '.current_fiscal_year_year' do
     expected_yr = Date.today.month < 7 ? Date.today.year - 1 : Date.today.year
     expect(test_fy_class.current_fiscal_year_year).to eq(expected_yr)
  end
  it '.current_planning_year_year' do
     expected_yr = Date.today.month < 7 ? Date.today.year : Date.today.year + 1
     expect(test_fy_class.current_planning_year_year).to eq(expected_yr)
  end
  it '.last_fiscal_year_year' do
    expected_yr = Date.today.month < 7 ? Date.today.year - 1 : Date.today.year
    expected_yr += SystemConfig.instance.num_forecasting_years
    expect(test_fy_class.last_fiscal_year_year).to eq(expected_yr)
  end
  describe '.to_year' do
    it 'must be a FY string else returns century' do
      expect(test_fy_class.to_year('2010')).to eq(2000)
    end
    it 'gets year' do
      expect(test_fy_class.to_year('FY 00-01')).to eq(2000)
      expect(test_fy_class.to_year('FY 01-02')).to eq(2001)
      expect(test_fy_class.to_year('FY 10-11')).to eq(2010)
      expect(test_fy_class.to_year('FY 11-12')).to eq(2011)
    end
  end
  it '.fiscal_year_year_on_date' do
    expect(test_fy_class.fiscal_year_year_on_date(Date.new(2015,5,1))).to eq(2014)
    expect(test_fy_class.fiscal_year_year_on_date(Date.new(2015,10,1))).to eq(2015)
  end
  it '.fiscal_year_end_date' do
    expect(test_fy_class.fiscal_year_end_date(Date.new(2015,5,1))).to eq(Date.new(2015,6,30))
    expect(test_fy_class.fiscal_year_end_date(Date.new(2015,10,1))).to eq(Date.new(2016,6,30))
  end
  it '.current_fiscal_year' do
    expected_yr = Date.today.month < 7 ? Date.today.year - 1 : Date.today.year
    expected_yr_start = expected_yr.to_s
    expected_yr_start = expected_yr_start[-2..expected_yr_start.length]
    expected_yr_end = (expected_yr+1).to_s
    expected_yr_end = expected_yr_end[-2..expected_yr_end.length]

    expect(test_fy_class.current_fiscal_year).to eq("FY #{expected_yr_start}-#{expected_yr_end}")
  end
  it '.current_planning_year' do
    expected_yr = Date.today.month < 7 ? Date.today.year : Date.today.year + 1
    expected_yr_start = expected_yr.to_s
    expected_yr_start = expected_yr_start[-2..expected_yr_start.length]
    expected_yr_end = (expected_yr+1).to_s
    expected_yr_end = expected_yr_end[-2..expected_yr_end.length]

    expect(test_fy_class.current_planning_year).to eq("FY #{expected_yr_start}-#{expected_yr_end}")
  end
  it '.fiscal_year_on_date' do
    expect(test_fy_class.fiscal_year_on_date(Date.new(2015,5,1))).to eq('FY 14-15')
    expect(test_fy_class.fiscal_year_on_date(Date.new(2015,10,1))).to eq('FY 15-16')
  end
  it '.fiscal_year' do
    expect(test_fy_class.fiscal_year(2015)).to eq('FY 15-16')
  end
  it '.get_all_fiscal_years' do
    fy_yr = Date.today.month < 7 ? Date.today.year - 4 - 1 : Date.today.year - 4
    results = []
    (fy_yr..test_fy_class.last_fiscal_year_year).each do |yr|
      results << ["FY #{(yr-2000).to_s}-#{(yr-2000+1).to_s}", yr]
    end
    expect(test_fy_class.get_all_fiscal_years).to eq(test_fy_class.get_fiscal_years(Date.today - 4.years))
    expect(test_fy_class.get_all_fiscal_years).to eq(results)
  end
  describe '.get_fiscal_years' do
    it 'no date or forecasting years' do
      results = []
      (test_fy_class.current_planning_year_year..test_fy_class.last_fiscal_year_year).each do |yr|
        results << ["FY #{(yr-2000).to_s}-#{(yr-2000+1).to_s}", yr]
      end
      expect(test_fy_class.get_fiscal_years).to eq(results)
    end
    it 'date given' do
      test_date1 = Date.new(2015,7,1)
      test_date2 = Date.new(2015,6,30)
      results = []
      (2014..test_fy_class.last_fiscal_year_year).each do |yr|
        results << ["FY #{(yr-2000).to_s}-#{(yr-2000+1).to_s}", yr]
      end
      expect(test_fy_class.get_fiscal_years(test_date1)).to eq(results[1..results.length-1])
      expect(test_fy_class.get_fiscal_years(test_date2)).to eq(results)
    end
    it 'forecasting years given' do
      current_planning_yr = Date.today.month < 7 ? Date.today.year : Date.today.year + 1
      results = []
      (0..4).each do |forecast_yr|
        results << ["FY #{(current_planning_yr+forecast_yr-2000).to_s}-#{(current_planning_yr+forecast_yr-2000+1).to_s}", current_planning_yr+forecast_yr]
      end
      expect(test_fy_class.get_fiscal_years(nil,4)).to eq(results)
    end
    it 'date and forecasting years given' do
      current_planning_yr = Date.today.month < 7 ? Date.today.year : Date.today.year + 1
      test_date1 = Date.new(2015,7,1)
      test_date2 = Date.new(2015,6,30)
      results = []
      (2014..2021).each do |yr|
        results << ["FY #{(yr-2000).to_s}-#{(yr-2000+1).to_s}", yr]
      end
      expect(test_fy_class.get_fiscal_years(test_date1, 6)).to eq(results[1..results.length-1])
      expect(test_fy_class.get_fiscal_years(test_date2, 7)).to eq(results)
    end
  end
  it '.get_planning_fiscal_years' do
    test_date = Date.new(2010,10,1)

    last_year = test_fy_class.last_fiscal_year_year
    results = []
    (2010..last_year).each do |yr|
      results << ["FY #{(yr-2000).to_s}-#{(yr-2000+1).to_s}", yr]
    end

    expect(test_fy_class.get_planning_fiscal_years(test_date)).to eq(results)
  end
  it '.fy_century' do
    expect(test_fy_class.fy_century(1950)).to eq(1900)
    expect(test_fy_class.fy_century(2050)).to eq(2000)
  end
end
