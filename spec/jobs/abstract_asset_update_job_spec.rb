require 'rails_helper'

RSpec.describe AbstractAssetUpdateJob, :type => :job do
  describe '.run' do
    it 'wrong object key' do
      expect{AbstractAssetUpdateJob.new('abcdefgh').run}.to raise_error(RuntimeError, "Can't find Asset with object_key abcdefgh")
    end
  end

  it '.check' do
    expect{AbstractAssetUpdateJob.new(nil).check}.to raise_error(ArgumentError, "object_key can't be blank ")
  end
end
