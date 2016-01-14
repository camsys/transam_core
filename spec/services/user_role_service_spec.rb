require 'rails_helper'

RSpec.describe UserRoleService, :type => :service do

  let(:test_service) { UserRoleService.new }
  let(:test_guest) { create(:guest) }
  let(:test_user) { create(:normal_user) }
  let(:test_manager) { create(:manager) }
  let(:test_admin) { create(:admin) }
  let(:test_tech) { create(:technical_contact) }

  describe '.assignable_roles' do
    it 'guest' do
        expect((test_service.assignable_roles test_guest).to_json).to eq(Role.where("name = 'guest' OR name = 'user'").to_json)
    end
    it 'user' do
      expect((test_service.assignable_roles test_user).to_json).to eq(Role.where("name = 'guest' OR name = 'user'").to_json)
    end
    it 'manager' do
      expect((test_service.assignable_roles test_manager).to_json).to eq(Role.roles.to_json)
    end
  end
  describe '.assignable_privileges' do
    it 'admin' do
      expect((test_service.assignable_privileges test_admin).to_json).to eq(Role.privileges.to_json)
    end
    it 'not admin' do
      expect((test_service.assignable_privileges test_tech).to_json).to eq(Role.where("name = 'technical_contact'").to_json)
    end
  end

  describe '.set_roles_and_privileges' do
    it 'add user role' do
      test_service.set_roles_and_privileges test_user, test_admin, nil, []
      test_user.reload

      expect(test_user.roles).to include(Role.find_by(:name => 'user'))
    end
    it 'add other roles' do
      test_service.set_roles_and_privileges test_user, test_admin, Role.find_by(:name => 'technical_contact').id.to_s, []
      test_user.reload

      expect(test_user.roles).to include(Role.find_by(:name => 'technical_contact'))
    end
    it 'add privileges' do
      test_service.set_roles_and_privileges test_user, test_admin, nil, [Role.find_by(:name => 'admin').id.to_s]
      test_user.reload

      expect(test_user.roles).to include(Role.find_by(:name => 'admin'))
    end
    it 'otherwise revoke' do
      test_user.roles << Role.find_by(:name => 'technical_contact')
      test_user.save!

      expect(test_user.roles).to include(Role.find_by(:name => 'technical_contact'))

      test_service.set_roles_and_privileges test_user, test_admin, Role.find_by(:name => 'admin').id.to_s, []
      test_user.reload

      expect(test_user.roles).not_to include(Role.find_by(:name => 'technical_contact'))
    end
  end

  it '.assign_role' do
    expect(test_user.roles).not_to include(Role.find_by(:name => 'technical_contact'))

    test_service.send(:assign_role, test_user, Role.find_by(:name => 'technical_contact'), test_admin)
    test_user.reload

    expect(test_user.roles).to include(Role.find_by(:name => 'technical_contact'))

    test_role = UsersRole.find_by(:user => test_user, :role => Role.find_by(:name => 'technical_contact'))
    expect(test_role.granted_by_user).to eq(test_admin)
    expect(test_role.granted_on_date).to eq(Date.today)
    expect(test_role.active).to be true
  end
  describe '.revoke_role' do
    it 'if does not exist, nothing to revoke' do
      test_user.add_role :user

      expect(test_user.roles).not_to include(Role.find_by(:name => 'admin'))

      test_service.send(:revoke_role, test_user, Role.find_by(:name => 'admin'), test_admin)
      test_user.reload

      expect(test_user.roles).not_to include(Role.find_by(:name => 'admin'))
    end
    it 'remove role' do
      test_user.add_role :user
      test_user.add_role :admin

      expect(test_user.roles).to include(Role.find_by(:name => 'admin'))

      test_service.send(:revoke_role, test_user, Role.find_by(:name => 'admin'), test_admin)
      test_user.reload

      expect(test_user.roles).not_to include(Role.find_by(:name => 'admin'))
    end
  end

end
