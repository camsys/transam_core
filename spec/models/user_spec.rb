require 'rails_helper'

RSpec.describe User, :type => :model do

  let(:org)           { build_stubbed(:organization) }
  let(:guest_user)    { build_stubbed(:guest) }
  let(:normal_user)   { build_stubbed(:normal_user) }
  let(:manager_user)  { build_stubbed(:manager) }
  let(:admin_user)    { build_stubbed(:admin) }

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------


  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  describe ".set_defaults" do
    it 'initializes new objects correctly' do
      expect(normal_user.timezone).to eql('Eastern Time (US & Canada)')
      expect(normal_user.num_table_rows).to eql(10)
    end
  end

  describe ".validates" do
    it 'validates new objects correctly' do
      #expect(normal_user.valid?).to eql(true)
    end
  end

  describe ".name" do
    it 'returns the correct name for a User' do
      expect(normal_user.name).to eql("joe normal")
      expect(manager_user.name).to eql("kate manager")
      expect(guest_user.name).to eql("bob guest")
    end
  end

  describe ".to_s" do
    it 'returns the correct default string for a User' do
      expect(normal_user.to_s).to eql(normal_user.name)
      expect(manager_user.to_s).to eql(manager_user.name)
    end
  end

  describe ".get_initials" do
    it 'returns the correct initials for a User' do
      expect(normal_user.get_initials).to eql("JN")
      expect(manager_user.get_initials).to eql("KM")
      expect(guest_user.get_initials).to eql("BG")
    end
  end

  describe ".has_role?" do
    it 'checks the roles correctly for a User' do
      normal_user.add_role :user
      expect(normal_user.has_role? 'user').to eql(true)
      expect(normal_user.has_role? :user).to eql(true)
      # test negatives
      expect(normal_user.has_role? :admin).to eql(false)
      expect(normal_user.has_role? :monkey).to eql(false)
      # test combinations of roles
      normal_user.add_role :manager
      expect(normal_user.has_role? :manager).to eql(true)
    end
  end

  describe ".organizations" do
    it 'returns the correct organizations for a User' do
      normal_user.organizations << org
      #expect(normal_user.organizations.count).to eql(1)
      #expect(normal_user.organization_ids).to eql([org.id])
    end
  end

  describe ".lock_access" do
    it 'logs when a users account is locked' do
      #expect(Rails.logger).to receive(:info).with("Locking account for user with email #{normal_user.email} at #{Time.now}")
      #normal_user.unlock_access!
    end
  end

  describe ".unlock_access" do
    it 'logs when a users account is unlocked' do
      #expect(Rails.logger).to receive(:info).with("Unlocking account for user with email #{normal_user.email} at #{Time.now}")
      #normal_user.lock_access!
    end
  end

end
