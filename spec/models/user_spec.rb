require 'rails_helper'

RSpec.describe User, :type => :model do

  let(:org)           { create(:organization) }
  let(:guest_user)    { create(:guest) }
  let(:normal_user)   { create(:normal_user) }
  let(:manager_user)  { create(:manager) }
  let(:admin_user)    { create(:admin) }

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  describe 'associations' do
    it 'has a filter' do
      expect(normal_user).to belong_to(:user_organization_filter)
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  it { should respond_to :rowify }

  describe ".rowify" do 
    it 'returns last name' do
      expect(normal_user.rowify[:last_name][:data]).to eq(normal_user.last_name)
      expect(normal_user.rowify[:first_name][:data]).to eq(normal_user.first_name)
      expect(normal_user.rowify[:organization][:data]).to eq(normal_user.organization.to_s)
      expect(normal_user.rowify[:email][:data]).to eq(normal_user.email)
      expect(normal_user.rowify[:phone][:data]).to eq(normal_user.phone.to_s)
      expect(normal_user.rowify[:phone_ext][:data]).to eq(normal_user.phone_ext.to_s)
      expect(normal_user.rowify[:title][:data]).to eq(normal_user.title.to_s)
      expect(normal_user.rowify[:role][:data]).to eq(normal_user.roles.try(:roles).try(:last).try(:label).to_s)
      expect(normal_user.rowify[:privileges][:data]).to eq(normal_user.roles.privileges.collect{|x| x.label}.join(', '))
      expect(normal_user.rowify[:status][:data]).to eq(normal_user.status)
    end
  end

  
  describe 'Get table prefs' do
    it 'responds to table_preferences' do
      expect(normal_user.table_preferences).to be(nil)
    end

    it 'expects the user bus table preferences to match the default' do
      expect(normal_user.table_preferences(:buses)).to eq(TablePreferences::DEFAULT_TABLE_PREFERENCES[:buses])
    end

    it 'returns the user-specifc preferences for buses' do
      table_prefs = eval(normal_user.table_prefs|| "{}")
      table_prefs[:bus] = {sort: :test, columns: [:test1, :test2]}
      normal_user.table_prefs = table_prefs 
      normal_user.save  
      expect(normal_user.table_preferences(:bus)[:sort]).to eq(:test)
    end
  end

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
      normal_user = create(:normal_user)
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
      expect(normal_user.organizations.count).to eql(1)
      expect(normal_user.organization_ids).to eql([org.id])
    end
  end

  describe ".unlock_access" do
    it 'logs when a users account is unlocked' do
      expect(Rails.logger).to receive(:info).with("Unlocking account for user with email #{normal_user.email} at #{Time.now}")
      normal_user.unlock_access!
    end
  end

  describe ".lock_access" do
    it 'logs when a users account is locked' do
      expect(Rails.logger).to receive(:info).with("Locking account for user with email #{normal_user.email} at #{Time.now}")
      normal_user.lock_access!
    end
  end

  it '#is_in_role() works as expected' do
    guest = create(:guest, email: '1@example.com', organization_id: org.id)
    normal_user = create(:normal_user, email: '2@example.com', organization_id: org.id)
    manager = create(:manager, email: '3@example.com', organization_id: org.id)
    admin = create(:admin, email: '4@example.com', organization_id: org.id)

    puts admin.roles.to_json
    expect(guest.is_in_role(Role.find_by(:name => 'guest').id)).to eql(true)
    expect(normal_user.is_in_role(Role.find_by(:name => 'user').id)).to eql(true)
    expect(manager.is_in_role(Role.find_by(:name => 'manager').id)).to eql(true)
    expect(admin.is_in_role(Role.find_by(:name => 'admin').id)).to eql(true)
  end

  it '.name works as expected' do
    expect(guest_user.name).to eql("bob guest")
    expect(normal_user.name).to eql("joe normal")
    expect(manager_user.name).to eql("kate manager")
    expect(admin_user.name).to eql("jill admin")
  end

end
