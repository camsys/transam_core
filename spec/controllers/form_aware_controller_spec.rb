require 'rails_helper'

RSpec.describe FormAwareController, :type => :controller do

  let(:test_form) { create(:form) }

  before(:each) do
    sign_in create(:admin)
  end

  it '.fire_workflow_event', :skip do

  end

  describe '.get_form_class' do
    describe 'exists' do
      it 'sets form type' do
        controller.params = {:form_id => test_form.object_key}
        controller.send(:get_form_class)

        expect(assigns(:form_type)).to eq(test_form)
      end
      it 'redirects otherwise' do
        expect(controller).to receive(:redirect_to).with("/404").and_return(true)

        controller.params = {:form_id => 'ABCDEFGHIJK'}
        controller.send(:get_form_class)

        expect(assigns(:form_type)).to be nil
      end
    end
    it 'user must be allowed' do
      expect(controller).to receive(:redirect_to).with("/404").and_return(true)

      test_form.update!(:roles => 'manager')
      controller.params = {:form_id => test_form.object_key}
      controller.send(:get_form_class)

      expect(assigns(:form_type)).to be nil
    end
  end
end
