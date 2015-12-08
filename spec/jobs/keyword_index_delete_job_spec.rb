require 'rails_helper'

RSpec.describe KeywordIndexDeleteJob, :type => :job do

  let(:test_asset) { create(:equipment_asset) }

  describe '.run' do
    it 'update keyword index' do
      KeywordIndexDeleteJob.new('Equipment', test_asset.object_key).run

      expect(KeywordSearchIndex.find_by(:object_key => test_asset.object_key)).to be nil
    end
    it 'wrong class', :skip do
      expect{KeywordIndexDeleteJob.new('nonexistent', test_asset.object_key).run}.to raise_error(RuntimeError, "Can't instantiate class nonexistent")
    end
    it 'wrong object key' do
      expect{KeywordIndexDeleteJob.new('Equipment', 'abcdefgh').run}.to raise_error(RuntimeError, "Can't find Equipment with object_key abcdefgh")
    end
  end

  it '.prepare' do
    test_asset.save!
    allow(Time).to receive(:now).and_return(Time.utc(2000,"jan",1,20,15,1))

    expect(Rails.logger).to receive(:info).with("Executing KeywordIndexDeleteJob at #{Time.now.to_s} for Keyword Index #{test_asset.object_key}")
    KeywordIndexDeleteJob.new('Equipment',test_asset.object_key).prepare
  end

  describe '.check' do
    it 'no class name' do
      expect{KeywordIndexDeleteJob.new(nil, 'Equipment').check}.to raise_error(ArgumentError, "class_name can't be blank ")
    end
    it 'no object key' do
      expect{KeywordIndexDeleteJob.new(test_asset.object_key, nil).check}.to raise_error(ArgumentError, "object_key can't be blank ")
    end
  end
end
