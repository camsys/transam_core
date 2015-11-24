require 'rails_helper'

RSpec.describe UserRoleService, :type => :service do

  let(:test_service) { UserRoleService.new }
  let(:test_user) { create(:normal_user) }
  let(:test_manager) { create(:admin) }

  describe '.set_roles_and_privileges' do
    it 'add user role' do
      test_service.set_roles_and_privileges test_user, test_manager, nil, []
      test_user.reload

      expect(test_user.roles).to include(Role.find_by(:name => 'user'))
    end
    it 'add other roles' do
      test_service.set_roles_and_privileges test_user, test_manager, Role.find_by(:name => 'technical_contact').id.to_s, []
      test_user.reload

      expect(test_user.roles).to include(Role.find_by(:name => 'technical_contact'))
    end
    it 'add privileges' do
      test_service.set_roles_and_privileges test_user, test_manager, nil, [Role.find_by(:name => 'admin').id.to_s]
      test_user.reload

      expect(test_user.roles).to include(Role.find_by(:name => 'admin'))
    end
    it 'otherwise revoke' do
      test_user.roles << Role.find_by(:name => 'technical_contact')
      test_user.save!

      expect(test_user.roles).to include(Role.find_by(:name => 'technical_contact'))

      test_service.set_roles_and_privileges test_user, test_manager, Role.find_by(:name => 'admin').id.to_s, []
      test_user.reload

      expect(test_user.roles).not_to include(Role.find_by(:name => 'technical_contact'))
    end
  end

  it '.assign_role' do
    expect(test_user.roles).not_to include(Role.find_by(:name => 'technical_contact'))

    test_service.send(:assign_role, test_user, Role.find_by(:name => 'technical_contact'), test_manager)
    test_user.reload

    expect(test_user.roles).to include(Role.find_by(:name => 'technical_contact'))

    test_role = UsersRole.find_by(:user => test_user, :role => Role.find_by(:name => 'technical_contact'))
    expect(test_role.granted_by_user).to eq(test_manager)
    expect(test_role.granted_on_date).to eq(Date.today)
    expect(test_role.active).to be true
  end
  describe '.revoke_role' do
    it 'if does not exist, nothing to revoke' do
      test_user.add_role :user

      expect(test_user.roles).not_to include(Role.find_by(:name => 'admin'))

      test_service.send(:revoke_role, test_user, Role.find_by(:name => 'admin'), test_manager)
      test_user.reload

      expect(test_user.roles).not_to include(Role.find_by(:name => 'admin'))
    end
    it 'remove role' do
      test_user.add_role :user
      test_user.add_role :admin

      expect(test_user.roles).to include(Role.find_by(:name => 'admin'))

      test_service.send(:revoke_role, test_user, Role.find_by(:name => 'admin'), test_manager)
      test_user.reload

      expect(test_user.roles).not_to include(Role.find_by(:name => 'admin'))
    end
  end

end
