require 'rails_helper'

RSpec.describe UsersRole, :type => :model do
  describe 'associations' do
    it 'belongs to user' do
      expect(UsersRole.column_names).to include('user_id')
    end
    it 'belongs to role' do
      expect(UsersRole.column_names).to include('role_id')
    end
    it 'has a grantor' do
      expect(UsersRole.column_names).to include('granted_by_user_id')
    end
    it 'has a revoker' do
      expect(UsersRole.column_names).to include('revoked_by_user_id')
    end
  end

  it '#allowable_params' do
    expect(UsersRole.allowable_params).to eq([
      :id,
      :user_id,
      :role_id,
      :granted_by_user_id,
      :revoked_by_user_id,
    ])
  end

  it '.set_defaults' do
    expect(UsersRole.new.active).to be false
  end
end
