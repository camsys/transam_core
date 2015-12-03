require 'rails_helper'

RSpec.describe AbstractAssetUpdateJob, :type => :job do
  describe '.run' do
    it 'no object key' do
      expect{AbstractAssetUpdateJob.new('abcdefgh').run}.to raise_error(RuntimeError, "Can't find Asset with object_key abcdefgh")
    end
  end
end
