require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_user)  { create(:admin) }
  let(:test_user2) { create(:normal_user) }

  before(:each) do
    User.destroy_all
    test_user.organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  describe 'GET index' do
    describe 'one organization' do
      it 'gets all users of a single org' do
        org = subject.current_user.organization
        get :index, {:organization_id => org.id}

        expect(assigns(:users)).to eq(org.users)
      end

      it 'get users for one organization with a specific role' do
        org = subject.current_user.organization
        get :index, {:organization_id => org.id, :role => 'admin'}

        expect(assigns(:users)).to eq(org.users.with_role('admin'))
      end

      it 'returns no users if wrong role' do
        org = subject.current_user.organization
        get :index, {:organization_id => org.id, :role => 'fake_role'}

        expect(assigns(:users).count).to eq(0)
      end
    end

    describe 'users from a list of orgs' do
      it 'returns all users' do
        get :index

        users = []
        subject.current_user.organizations.each do |org|
          users << org.users
        end

        users.flatten!.uniq

        expect(assigns(:users)).to eq(users)
      end

      it 'returns all users with a role' do
        get :index, {:role => 'admin'}

        users = []
        subject.current_user.organizations.each do |org|
          users << org.users.with_role('admin')
        end

        users.flatten!.uniq

        expect(assigns(:users)).to eq(users)
      end

      it 'returns no users if wrong role' do
        get :index, {:role => 'fake_role'}

        expect(assigns(:users).count).to eq(0)
      end
    end
  end

  it 'GET show' do
    get :show, {:id => subject.current_user.object_key}

    expect(assigns(:user)).to eq(subject.current_user)
  end

  it 'GET new' do
    get :new

    expect(assigns(:user).organization).to eq(assigns(:organization))
  end

  describe 'GET edit' do
    it 'can view own' do
      get :edit, {:id => subject.current_user.object_key}
      expect(assigns(:user)).to eq(subject.current_user)
    end

    it 'support can view others' do
      get :edit, {:id => test_user2.object_key}

      expect(assigns(:user)).to eq(test_user2)
    end
  end

  describe 'GET reset_password' do
    it 'can view own' do
      get :reset_password, {:id => subject.current_user.object_key}
      expect(assigns(:user)).to eq(subject.current_user)
    end

    it 'support can view others' do
      get :reset_password, {:id => test_user2.object_key}
      expect(assigns(:user)).to eq(test_user2)
    end
  end

  describe 'GET change_password' do
    it 'can view own' do
      get :change_password, {:id => subject.current_user.object_key}
      expect(assigns(:user)).to eq(subject.current_user)
    end

    it 'support can view others' do
      get :change_password, {:id => test_user2.object_key}
      expect(assigns(:user)).to eq(test_user2)
    end
  end

  describe 'GET settings' do
    it 'can view own' do
      get :settings, {:id => subject.current_user.object_key}
      expect(assigns(:user)).to eq(subject.current_user)
    end

    it 'support can view others' do
      get :settings, {:id => test_user2.object_key}
      expect(assigns(:user)).to eq(test_user2)
    end
  end

  describe 'GET profile_photo' do
    it 'can view own' do
      get :profile_photo, {:id => subject.current_user.object_key}
      expect(assigns(:user)).to eq(subject.current_user)
    end

    it 'support can view others' do
      get :profile_photo, {:id => test_user2.object_key}
      expect(assigns(:user)).to eq(test_user2)
    end
  end

  it 'POST create' do
    post :create, {"user" => {:password => SecureRandom.base64(64), "first_name"=>"Lydia", "last_name"=>"Chang", "email"=>"lchang@camsys.com", "title"=>"Software Engineer", "external_id"=>"", "phone"=>"617-354-1067", "phone_ext"=>"", "timezone"=>"Eastern Time (US & Canada)", "address1"=>"400 CambridgePark Drive", "address2"=>"", "city"=>"Cambridge", "state"=>"MA", "zip"=>"02140", "organization_id"=>"1", "role_ids"=>Role.find_by(:name => 'manager').id.to_s, :privilege_ids => []}}

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
    expect(assigns(:user).organization).to eq(Organization.first)
    expect(assigns(:user).has_role? :manager).to be true
  end

  describe 'PUT update' do
    it 'can update ownself' do
      put :update, {"id" => subject.current_user.object_key, "user"=>{'title' => 'new promotion', :role_ids => 2, :privilege_ids => []}}

      expect(assigns(:user).title).to eq('new promotion')
    end

    it 'a support can update anyone' do
      put :update, {"id" => test_user2.object_key, "user"=>{'title' => 'test user2 new promotion', :role_ids => 2, :privilege_ids => []}}

      expect(assigns(:user).title).to eq('test user2 new promotion')
    end
  end

  it 'PUT update_password' do
    put :update_password, {:id => subject.current_user.object_key, :user => {:password => 'newpassword'}}

    expect(assigns(:user)).to eq(subject.current_user)
  end

  it 'DELETE destroy' do
    User.unscoped.where(:last_name => 'Chang').delete_all if User.unscoped.find_by(:last_name => 'Chang')
    create(:normal_user, :last_name => 'Chang')

    delete :destroy, {:id => User.find_by(:last_name => 'Chang').object_key}

    inactive_user = User.unscoped.find_by(:last_name => 'Chang')
    expect(inactive_user).not_to be nil
    expect(assigns(:user)).to eq(inactive_user)
    expect(assigns(:user).active).to be false
  end
end
