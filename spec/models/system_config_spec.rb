require 'rails_helper'

RSpec.describe SystemConfig, :type => :model do

  let(:test_config) { SystemConfig.first }

  describe 'validations' do
    it 'must have a customer' do
      test_config.customer_id = nil
      expect(test_config.valid?).to be false
    end
    it 'must have a FY start' do
      test_config.start_of_fiscal_year = nil
      expect(test_config.valid?).to be false
    end
    it 'must have a map title provider' do
      test_config.map_tile_provider = nil
      expect(test_config.valid?).to be false
    end
    it 'must have a srid' do
      test_config.srid = nil
      expect(test_config.valid?).to be false
    end
    it 'must have a min lat' do
      test_config.min_lat = nil
      expect(test_config.valid?).to be false
    end
    it 'must have a min lon' do
      test_config.min_lon = nil
      expect(test_config.valid?).to be false
    end
    it 'must have a max lat' do
      test_config.max_lat = nil
      expect(test_config.valid?).to be false
    end
    it 'must have a max lon' do
      test_config.max_lon = nil
      expect(test_config.valid?).to be false
    end
    it 'must have a search radius' do
      test_config.search_radius = nil
      expect(test_config.valid?).to be false
    end
    it 'must have a search units' do
      test_config.search_units = nil
      expect(test_config.valid?).to be false
    end
    it 'must have a geocoder components' do
      test_config.geocoder_components = nil
      expect(test_config.valid?).to be false
    end
    it 'must have a geocoder region' do
      test_config.geocoder_region = nil
      expect(test_config.valid?).to be false
    end
    it 'must have forecasting years' do
      test_config.num_forecasting_years = nil
      expect(test_config.valid?).to be false
    end
    it 'must have reporting years' do
      test_config.num_reporting_years = nil
      expect(test_config.valid?).to be false
    end
  end

  it '#instance' do
    expect(SystemConfig.instance).to eq(test_config)
  end
  describe '#transam_module_loaded?' do
    it 'version' do
      expect(SystemConfig.transam_module_loaded?('core', '>= 0.0.0.0')).to be true
    end
    it 'no version' do
      expect(SystemConfig.transam_module_loaded?('core')).to be true
    end
  end
  it '#transam_modules' do
    expect(SystemConfig.transam_modules).to eq(Gem::Specification::find_all_by_name("transam_core"))
  end
  it '#transam_module_names' do
    expect(SystemConfig.transam_module_names).to eq(['core'])
  end

  it '.default_state_code' do
    pending('TODO')
    fail
  end
  it '.epoch' do
    expect(test_config.epoch).to eq(Rails.application.config.epoch)
  end
  it '.max_rows_returned' do
    expect(test_config.max_rows_returned).to eq(Rails.application.config.max_rows_returned)
  end
  it '.geocoder_bounds' do
    expect(test_config.geocoder_bounds).to eq([[test_config.min_lat, test_config.min_lon], [test_config.max_lat, test_config.max_lon]])
  end
  it '.map_bounds' do
    expect(test_config.map_bounds).to eq([[test_config.min_lat, test_config.min_lon], [test_config.max_lat, test_config.max_lon]])
  end
end
