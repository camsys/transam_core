require 'rails_helper'

RSpec.describe FormsController, :type => :controller do

  before(:each) do
    sign_in create(:admin)
  end

  let(:test_form) { create(:form) }

  it 'GET index' do
    test_form.save!
    test_form2 = create(:form, :roles => 'manager')

    get :index
    expect(assigns(:forms)).to include(test_form)
    expect(assigns(:forms)).not_to include(test_form2)
  end
  it 'GET show', :skip do
    get :show, params: {:id => test_form.object_key}

    expect(assigns(:form)).to eq(test_form)
  end
  it 'negative test' do
    get :show, params: {:id => 'ABCDEFGHIJK'}

    expect(assigns(:form)).to be nil
    expect(response).to redirect_to('/404')
  end
end
