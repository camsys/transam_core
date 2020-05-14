require 'rails_helper'

RSpec.describe UsersController, :type => :controller do

  let(:test_user)  { create(:admin) }
  let(:test_user2) { create(:normal_user) }

  before(:each) do
    create(:admin, first_name: 'system', last_name: 'user')

    test_user2.organizations = [test_user2.organization]
    test_user2.viewable_organizations = [test_user2.organization]
    test_user2.save!

    test_user.organizations = [test_user.organization, test_user2.organization]
    test_user.viewable_organizations = [test_user.organization, test_user2.organization]
    test_user.save!
    sign_in test_user
  end


  describe 'GET table' do

    it 'returns all users' do
      get :table
      expect(response).to be_success
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["count"]).to eq(User.count)
    end

    it 'returns the first 10 users' do
      get :table,  params: {page: 0, page_size: 10}
      expect(response).to be_success
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["count"]).to eq(User.count)
      expect(parsed_response["rows"].count).to eq(10)
      expect(parsed_response["rows"].first["Last"]).to eq(User.first.last_name)
    end

    it 'returns users associated with the last organization' do
      org = Organization.last
      get :table,  params: {search: org.short_name}
      expect(response).to be_success
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["count"]).to eq(User.where(organization: org).count)
    end

  end

  describe 'GET Table Preferences' do 
    it 'returns a users preferred tables' do 
      get :table_preferences, params: {table_code: "users"}
      expect(response).to be_success
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["sort"].first["column"].to_s).to eq(TablePreferences::DEFAULT_TABLE_PREFERENCES[:users][:sort].first[:column].to_s)
    end
  end

  describe 'PUT Table Preferences' do 
    it 'returns a users preferred tables' do 
      params = {
                "table_code": "users",
                "sort":[
                    {"column": "first", "order": "descending"},
                    {"column": "last", "order": "descending"}
                  ]
                }
      put :update_table_preferences, params: params
      expect(response).to be_success
      parsed_response = JSON.parse(response.body)

      get :table_preferences, params: {table_code: "users"}
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["sort"].first["column"].to_s).to eq("first")
      expect(parsed_response["sort"].first["order"].to_s).to eq("descending")
      expect(parsed_response["sort"].last["column"].to_s).to eq("last")

      get :table_preferences, params: {table_code: "buses"}
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["sort"].first["column"].to_s).to eq(TablePreferences::DEFAULT_TABLE_PREFERENCES[:buses][:sort].first[:column].to_s)
    end
  end

  describe 'GET index' do

    describe 'users from a list of orgs' do
      it 'returns all users' do
        get :index

        expect(assigns(:users)).to include(test_user)
        expect(assigns(:users)).to include(test_user2)
      end

      it 'returns all users with a role' do
        get :index, params: {:role => 'admin'}

        expect(assigns(:users)).to include(test_user)
        expect(assigns(:users)).not_to include(test_user2)
      end

      it 'returns no users if wrong role' do
        get :index, params: {:role => 'fake_role'}

        expect(assigns(:users).count).to eq(0)
      end
    end
  end

  it 'GET show' do
    get :show, params: {:id => subject.current_user.object_key}

    expect(assigns(:user)).to eq(subject.current_user)
  end

  it 'GET new' do
    get :new

    expect(assigns(:user).to_json).to eq(User.new.to_json)
  end

  describe 'GET edit' do
    it 'can view own' do
      get :edit, params: {:id => subject.current_user.object_key}
      expect(assigns(:user)).to eq(subject.current_user)
    end

    it 'support can view others' do
      get :edit, params: {:id => test_user2.object_key}

      expect(assigns(:user)).to eq(test_user2)
    end
  end

  describe 'GET reset_password' do
    it 'can view own' do
      get :reset_password, params: {:id => subject.current_user.object_key}
      expect(assigns(:user)).to eq(subject.current_user)
    end

    it 'support can view others' do
      get :reset_password, params: {:id => test_user2.object_key}
      expect(assigns(:user)).to eq(test_user2)
    end
  end

  describe 'GET change_password' do
    it 'can view own' do
      get :change_password, params: {:id => subject.current_user.object_key}
      expect(assigns(:user)).to eq(subject.current_user)
    end

    it 'support can view others' do
      get :change_password, params: {:id => test_user2.object_key}
      expect(assigns(:user)).to eq(test_user2)
    end
  end

  describe 'GET settings' do
    it 'can view own' do
      get :settings, params: {:id => subject.current_user.object_key}
      expect(assigns(:user)).to eq(subject.current_user)
    end

    it 'support can view others' do
      get :settings, params: {:id => test_user2.object_key}
      expect(assigns(:user)).to eq(test_user2)
    end
  end

  describe 'GET profile_photo' do
    it 'can view own' do
      get :profile_photo, params: {:id => subject.current_user.object_key}
      expect(assigns(:user)).to eq(subject.current_user)
    end

    it 'support can view others' do
      get :profile_photo, params: {:id => test_user2.object_key}
      expect(assigns(:user)).to eq(test_user2)
    end
  end

  it 'POST create' do
    test_org = create(:organization)
    post :create, params: {"user" => {:password => SecureRandom.base64(64), "first_name"=>"Lydia", "last_name"=>"Chang", "email"=>"lchang@camsys.com", "title"=>"Software Engineer", "external_id"=>"", "phone"=>"617-354-1067", "phone_ext"=>"", "timezone"=>"Eastern Time (US & Canada)", "address1"=>"400 CambridgePark Drive", "address2"=>"", "city"=>"Cambridge", "state"=>"MA", "zip"=>"02140", "organization_id"=>test_org.id, "role_ids"=>Role.find_by(:name => 'manager').id.to_s, :privilege_ids => [], :organization_ids => ""}}

    expect(assigns(:user).first_name).to eq('Lydia')
    expect(assigns(:user).last_name).to eq('Chang')
    expect(assigns(:user).email).to eq('lchang@camsys.com')
    expect(assigns(:user).title).to eq('Software Engineer')
    expect(assigns(:user).phone).to eq('617-354-1067')
    expect(assigns(:user).timezone).to eq('Eastern Time (US & Canada)')
    expect(assigns(:user).address1).to eq('400 CambridgePark Drive')
    expect(assigns(:user).city).to eq('Cambridge')
    expect(assigns(:user).state).to eq('MA')
    expect(assigns(:user).zip).to eq('02140')
    expect(assigns(:user).organization).to eq(test_org)
    expect(assigns(:user).has_role? :manager).to be true
  end

  describe 'PUT update' do
    it 'can update ownself' do
      put :update, params: {"id" => subject.current_user.object_key, "user"=>{'title' => 'new promotion', :role_ids => 2, :privilege_ids => [], :organization_ids => ""}}

      expect(assigns(:user).title).to eq('new promotion')
    end

    it 'a support can update anyone' do
      put :update, params: {"id" => test_user2.object_key, "user"=>{'title' => 'test user2 new promotion', :role_ids => 2, :privilege_ids => [], :organization_ids => ""}}

      expect(assigns(:user).title).to eq('test user2 new promotion')
    end
  end

  it 'PUT update_password' do
    put :update_password, params: {:id => subject.current_user.object_key, :user => {:password => 'newpassword'}}

    expect(assigns(:user)).to eq(subject.current_user)
  end

  it 'DELETE destroy' do
    User.unscoped.where(:last_name => 'Chang').delete_all if User.unscoped.find_by(:last_name => 'Chang')
    create(:normal_user, :last_name => 'Chang', :organization => test_user.organization)

    delete :destroy, params: {:id => User.find_by(:last_name => 'Chang').object_key}

    inactive_user = User.unscoped.find_by(:last_name => 'Chang')
    expect(inactive_user).not_to be nil
    expect(assigns(:user)).to eq(inactive_user)
    expect(assigns(:user).active).to be false
  end
end
