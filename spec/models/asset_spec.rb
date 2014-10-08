require 'rails_helper'

RSpec.describe Asset, :type => :model do
    # policy = build_stubbed(:policy)
    let(:buslike_asset) { build_stubbed(:buslike_asset) }
    let(:persisted_buslike_asset) { create(:buslike_asset) }


  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
  # describe ".new_asset" do # pending
  #   it "returns a typed asset" do
  #     pending "There is a coupling here. Do we need to test the seed data?"
  #     a = Asset.new_asset(FactoryGirl.build(:asset_subtype))

  #     expect(a.class).to eq("AssetType")
  #   end
  # end

  # describe ".get_typed_asset" do
  #   it "types an untyped asset" do
  #     expect(Asset.get_typed_asset(buslike_asset).class).to eq(Vehicle)
  #   end

  #   it "types an already typed asset" do
  #     expect(Asset.get_typed_asset(buslike_asset).class).to eq(Vehicle)
  #   end

  #   it "returns nil when handed nothing" do
  #     expect(Asset.get_typed_asset(nil)).to be_nil
  #   end
  # end

  describe ".event_classes" do
    it 'returns the right event classes for an asset' do
      expect(Asset.event_classes.count).to eq(7) # should enumerate those tests...
    end
  end


  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  describe "#age" do
    it 'returns 0 for assets manufactured in the future' do
      # Built next year -- should always return 0
      buslike_asset.manufacture_year = Date.today.year + 1.year

      expect(buslike_asset.age).to eql(0)
    end

    it 'returns 0 for assets manufactured in this year' do
      # Built this year
      buslike_asset.manufacture_year = Date.today.year

      expect(buslike_asset.age).to eql(0)
    end

    it 'returns a positive value for an asset manufactured in the past' do
      # Built 6 years ago
      buslike_asset.manufacture_year = Date.today.year - 6

      expect(buslike_asset.age).to eql(6)
    end

    it 'calculates its age on a specific date properly' do
      buslike_asset.manufacture_year = Date.today.year

      on_date = Date.today + 10.years
      expect(buslike_asset.age(on_date)).to eql(10)

      on_date = Date.today
      expect(buslike_asset.age(on_date)).to eql(0)

      on_date = Date.today - 10.years
      expect(buslike_asset.age(on_date)).to eql(0)
    end
  end

  describe '#create_typed_event' do

    it 'raises an ArgumentError when creating an event which is not defined for the asset class' do
      class ABCUpdateEvent < AssetEvent; end
      expect{ buslike_asset.create_typed_event(ABCUpdateEvent) }.to raise_error(ArgumentError)
    end
    
    describe "for abstract Asset class" do
      it 'returns only for the asset events defined on the asset class' do
        expect(buslike_asset.create_typed_event(ConditionUpdateEvent).class).to eq(ConditionUpdateEvent)
      end
    end
  end


  describe '#history' do
    it 'holds events of all types' do
      buslike_asset.condition_updates.create(attributes_for :condition_update_event)
      buslike_asset.service_status_updates.create(attributes_for :service_status_update_event)

      expect(buslike_asset.history.count).to eq(2)
    end

    it 'defaults to no events' do
      expect(buslike_asset.history.count).to eq(0)
    end

    it 'is ordered correctly' do
      buslike_asset.condition_updates.create(attributes_for :condition_update_event)

      event = AssetEvent.as_typed_event buslike_asset.history.first
      expect(event.condition_type.name).to eq("Adequate")
      expect(event.assessed_rating).to eq(3)
      expect(event.current_mileage).to eq(25000)
    end
  end


  describe "#searchable_fields" do
    it 'inherits down the tree' do
      asset_searchables = [ 'object_key', 'asset_tag', 'manufacture_year']

      expect(buslike_asset.searchable_fields).to eql(asset_searchables)
    end
  end

  describe "#type_of?" do
    it 'only looks up the tree' do
      expect(buslike_asset.type_of? :geolocatable_asset).to be false
    end

    it 'should return true/false when passed a symbol, string or classname' do
      expect(buslike_asset.type_of?(:asset)).to be true
      expect(buslike_asset.type_of?("asset")).to be true
      expect(buslike_asset.type_of?(Asset)).to be true
    end
  end

  describe "#initialize_policy_items" do #pending
    pending "Need some specs"
  end

  describe '#copy' do
    describe "with a cleanse" do
      it 'copies all (non-cleansed) fields for an abstract type' do
        copied_bus = buslike_asset.copy

        %w(class organization_id asset_type_id asset_subtype_id manufacturer_id manufacturer_model manufacture_year
          purchase_date expected_useful_miles fuel_type_id).each do |attribute_name|
          expect(copied_bus.send(attribute_name)).to eq(buslike_asset.send(attribute_name)),
          "#{attribute_name} expected: #{persisted_buslike_asset.send(attribute_name)}\n         got: #{copied_bus.send(attribute_name)}"
        end
      end

      it 'clears out cleansable_fields' do
        copied_bus = persisted_buslike_asset.copy

        %w(asset_tag policy_replacement_year estimated_replacement_year estimated_replacement_cost
          scheduled_replacement_year scheduled_rehabilitation_year scheduled_disposition_year replacement_reason_type_id
          in_backlog reported_condition_type_id reported_condition_rating reported_condition_date reported_mileage
          estimated_condition_type_id estimated_condition_rating service_status_type_id estimated_value
          disposition_type_id disposition_date license_plate).each do |attribute_name|
          expect(copied_bus.send(attribute_name)).to be_blank,
          "expected '#{attribute_name}' to be blank, got #{copied_bus.send(attribute_name)}"
        end
      end
    end

    describe 'without a cleanse' do
      it 'does not clear out cleansable_fields' do
        buslike_asset.license_plate = "ABC-123" # test a concrete class attribute
        copied_bus = buslike_asset.copy(false)

        expect(copied_bus.license_plate).not_to be_blank
      end

      it 'does not keep attached objects when passed a False' do
        persisted_buslike_asset.comments.create(:comment => "Test Comment")
        copied_bus = persisted_buslike_asset.copy(false)

        expect(copied_bus.comments.length).to eq(0)
      end
    end
  end

  describe '#calculate_replacement_year' do
    pending "I need to learn about policies"
  end

  describe '#calculate_estimated_replacement_year' do
    pending "I need to learn about policies"
  end

  describe '#update_sogr' do
    pending "I need to learn about policies"
  end

  ################ TESTS THAT ASSOCIATIONS HOLD ON CRUD METHODS ################
  ### Four relationships to check: ###
  # asset_group belongs_to asset      asset.asset_groups.include? asset_group
  # asset has_many asset_groups
  # asset belongs_to asset_group      asset_group.assets.include? asset
  # asset_group has_many assets

  describe '#asset_groups' do
    let(:test_asset_group) { create(:asset_group, :assets => [persisted_buslike_asset]) }
    # Asset group with no assets
    it 'can have none' do
      expect(persisted_buslike_asset.asset_groups.count).to eq(0)
    end

    it 'associations hold on asset_group create' do
      expect(persisted_buslike_asset.asset_groups.include? test_asset_group).to be true
      expect(test_asset_group.assets.include? persisted_buslike_asset).to be true
    end

    it 'associations hold on asset_group destroy' do
      test_asset_group_id = test_asset_group.id
      test_asset_group.destroy

      expect(test_asset_group.assets.length).to eq(0)
      expect(persisted_buslike_asset.asset_group_ids.include? test_asset_group_id).to be false
    end
  end

end
