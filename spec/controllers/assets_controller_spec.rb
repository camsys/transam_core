require 'rails_helper'

RSpec.describe AssetsController, :type => :controller do

  before(:each) do
    User.destroy_all
    sign_in FactoryGirl.create(:admin)
  end


  describe "GET Index" do
    it 'returns in less than 30 seconds' do

      t_start = Time.now
      get 'index'
      t_finish = Time.now

      expect(t_finish - t_start).to be < 30.seconds
    end
  end

end
