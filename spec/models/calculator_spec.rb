require 'spec_helper'

describe "Calculator Tests" do
  pending "add some examples to (or delete) #{__FILE__}"
  before(:each) {
    @policy = create(:policy)
    @bus = create(:bus)
    @lrc = create(:light_rail_car)
    @shelter = create(:bus_shelter)
    @adminb = create(:administration_building)
  }

  it 'Straight Line Estimator works as expected' do
    calculator = StraightLineEstimationCalculator.new(@policy)

    # Test case where asset incorrectly reports its date as being in the future
    @bus.manufacture_year = Date.today.year + 1
    expect(calculator.calculate(@bus).to_f).to eql(5.0)
    expect(calculator.last_servicable_year(@bus)).to eql(@bus.manufacture_year + 12)

    # Bus is 0 years old
    @bus.manufacture_year = Date.today.year
    expect(calculator.calculate(@bus).to_f).to eql(5.0)
    expect(calculator.last_servicable_year(@bus)).to eql(@bus.manufacture_year + 12)

    # Bus is halfway through its useful life
    @bus.manufacture_year = Date.today.year - 6
    expect(calculator.calculate(@bus).to_f).to eql(3.75)
    expect(calculator.last_servicable_year(@bus)).to eql(@bus.manufacture_year + 12)

    # Bus is at the end of its useful life
    @bus.manufacture_year = Date.today.year - 12
    expect(calculator.calculate(@bus).to_f).to eql(2.5)
    expect(calculator.last_servicable_year(@bus)).to eql(@bus.manufacture_year + 12)

    # Bus is past its useful life and should be halfway between the condition threshold (2.5)
    # and the minimum condition (i.e. 1.0)
    @bus.manufacture_year = Date.today.year - 18
    expect(calculator.calculate(@bus).to_f).to eql(1.25)
    expect(calculator.last_servicable_year(@bus)).to eql(@bus.manufacture_year + 12)

    # Bus is past its useful life and should be at the minimum condition
    @bus.manufacture_year = Date.today.year - 24
    expect(calculator.calculate(@bus).to_f).to eql(1.0)
    expect(calculator.last_servicable_year(@bus)).to eql(@bus.manufacture_year + 12)

    # Bus is past its useful life and the estimator should limit the estimated
    # condition to the minimum limit i.e. 1
    @bus.manufacture_year = Date.today.year - 30
    expect(calculator.calculate(@bus).to_f).to eql(1.0)
    expect(calculator.last_servicable_year(@bus)).to eql(@bus.manufacture_year + 12)

    # Test the case where there is a condition update
    condition_update = create(:condition_update1, :asset_id => @bus.id)
    condition_update.current_mileage = nil
    condition_update.event_date = Date.today

    # Run the same tests with the sequence of dates and ratings
    @bus.manufacture_year = Date.today.year
    condition_update.assessed_rating = 5.0
    condition_update.save
    expect(calculator.calculate(@bus).to_f).to eql(5.0)
    expect(calculator.last_servicable_year(@bus)).to eql(@bus.manufacture_year + 12)

    @bus.manufacture_year = Date.today.year - 6
    condition_update.assessed_rating = 3.75
    condition_update.save
    expect(calculator.calculate(@bus).to_f).to eql(3.75)
    expect(calculator.last_servicable_year(@bus)).to eql(@bus.manufacture_year + 12)

    @bus.manufacture_year = Date.today.year - 12
    condition_update.assessed_rating = 2.5
    condition_update.save
    expect(calculator.calculate(@bus).to_f).to eql(2.5)
    expect(calculator.last_servicable_year(@bus)).to eql(@bus.manufacture_year + 12)

    @bus.manufacture_year = Date.today.year - 18
    condition_update.assessed_rating = 1.25
    condition_update.save
    expect(calculator.calculate(@bus).to_f).to eql(1.25)
    expect(calculator.last_servicable_year(@bus)).to eql(@bus.manufacture_year + 12)

    # Test a mileage update
    @bus.manufacture_year = Date.today.year - 6
    condition_update.assessed_rating = 3.75
    condition_update.current_mileage = 250000
    condition_update.save
    expect(calculator.calculate(@bus).to_f).to eql(3.75)
    expect(calculator.last_servicable_year(@bus)).to eql(@bus.manufacture_year + 12)

  end


  it 'Purchase Price Plus Interest Calculator works as expected' do
    calculator = PurchasePricePlusInterestCalculator.new(@policy)

    # A new bus
    @bus.manufacture_year = Date.today.year
    @bus.save!
    expect(calculator.calculate(@bus).to_i).to eql(367133)

    # A bus before the end of its useful life (1-12 years)
    # will return the same value as a new bus, because
    # what's being calculated is the total amount that will
    # be paid over the course of its useful life
    @bus.manufacture_year = Date.today.year - 6
    @bus.save!
    expect(calculator.calculate(@bus).to_i).to eql(367133)

    # A bus at the end of its useful life
    @bus.manufacture_year = Date.today.year  - 12
    @bus.save!
    expect(calculator.calculate(@bus).to_i).to eql(367133)

    # A bus past the end of its useful life, accruing additional interest?
    @bus.manufacture_year = Date.today.year - 18
    @bus.save!
    expect(calculator.calculate(@bus).to_i).to eql(425608)

    # A bus way past the end of its useful life, accruing additional interest?
    @bus.manufacture_year = Date.today.year - 24
    @bus.save!
    expect(calculator.calculate(@bus).to_i).to eql(508198)
  end

  it 'Replacement Cost Calculator works as expected' do
    calculator = ReplacementCostCalculator.new(@policy)
    expect(calculator.calculate(@bus).to_i).to eql(300000)
  end

  it 'Replacement Cost Plus Interest Calculator works as expected' do
    calculator = ReplacementCostPlusInterestCalculator.new(@policy)

    # A new bus
    @bus.manufacture_year = Date.today.year
    @bus.save!
    expect(calculator.calculate(@bus).to_i).to eql(440560)

    # A bus before the end of its useful life (1-12 years)
    # will return the same value as a new bus, because
    # what's being calculated is the total amount that will
    # be paid over the course of its useful life
    @bus.manufacture_year = Date.today.year - 6
    @bus.save!
    expect(calculator.calculate(@bus).to_i).to eql(440560)

    # A bus at the end of its useful life
    @bus.manufacture_year = Date.today.year  - 12
    @bus.save!
    expect(calculator.calculate(@bus).to_i).to eql(440560)

    # A bus past the end of its useful life
    @bus.manufacture_year = Date.today.year - 18
    @bus.save!
    expect(calculator.calculate(@bus).to_i).to eql(510729)

    # A bus way past the end of its useful life, accruing additional interest?
    @bus.manufacture_year = Date.today.year - 24
    @bus.save!
    expect(calculator.calculate(@bus).to_i).to eql(609838)
  end

  it 'Service Life Age Only calculator works as expected' do
    calculator = ServiceLifeAgeOnly.new(@policy)

    # A new bus
    @bus.manufacture_year = Date.today.year
    expect(calculator.calculate(@bus).to_i).to eql(2026)

    # A bus halfway through its useful life
    @bus.manufacture_year = Date.today.year - 6
    expect(calculator.calculate(@bus).to_i).to eql(2020)

    # A bus at the end of its useful life
    @bus.manufacture_year = Date.today.year  - 12
    expect(calculator.calculate(@bus).to_i).to eql(2014)

    # A bus past the end of its useful life
    @bus.manufacture_year = Date.today.year - 18
    expect(calculator.calculate(@bus).to_i).to eql(2008)
  end

  it 'Service Life Age And Condition calculator works as expected' do
    calculator = ServiceLifeAgeAndCondition.new(@policy)

    # A new bus
    @bus.manufacture_year = Date.today.year
    expect(calculator.calculate(@bus).to_i).to eql(2026) # 12 years

    # A bus halfway through its useful life
    @bus.manufacture_year = Date.today.year - 6
    expect(calculator.calculate(@bus).to_i).to eql(2020)

    # A bus at the end of its useful life
    @bus.manufacture_year = Date.today.year  - 12
    expect(calculator.calculate(@bus).to_i).to eql(2014)

    # A bus past the end of its useful life
    @bus.manufacture_year = Date.today.year - 18
    expect(calculator.calculate(@bus).to_i).to eql(2008)

    # Test the case when there are condition updates

    # A condition update has a failing rating after 8 years
    condition_update = create(:update2, :asset_id => @bus.id)
    @bus.manufacture_year = Date.today.year
    expect(calculator.calculate(@bus).to_i).to eql(2022)

    # A condition update taps out the miles after 6 years
    condition_update = create(:update3, :asset_id => @bus.id)
    @bus.manufacture_year = Date.today.year
    expect(calculator.calculate(@bus).to_i).to eql(2020)

  end

  it 'calculations in TermEstimationCalculator work as expected' do
    calculator = TermEstimationCalculator.new(@policy)

    ## Vehicle ##

    # A new bus
    @bus.manufacture_year = Date.today.year
    @bus.save!
    expect(calculator.calculate(@bus)).to eql(5.583333333333333)
    # An older bus
    @bus.manufacture_year = Date.today.year - 6
    @bus.save!
    expect(calculator.calculate(@bus)).to eql(2.963952715121931486)

    ## Rail Car ##

    # A new Rail Car
    @lrc.manufacture_year = Date.today.year
    @lrc.save!
    expect(calculator.calculate(@lrc)).to eql(5.75)

    # An older Rail Car
    @lrc.manufacture_year = Date.today.year - 6
    @lrc.save!
    expect(calculator.calculate(@lrc)).to eql(4.022403394003351)

    ## Locomotives don't have a set term curve,
    ## so this test would be identical to some of the tests above

    ## Transit Facility ##

    # A new Transit Facility
    @shelter.manufacture_year = Date.today.year
    @shelter.save!
    expect(calculator.calculate(@shelter)).to eql(4.995028080975533)
    # An older Transit Facility
    @shelter.manufacture_year = Date.today.year - 6
    @shelter.save!
    expect(calculator.calculate(@shelter)).to eql(4.9771416003492135)

    ## Support Facility ##

    # A new Support Facility
    @adminb.manufacture_year = Date.today.year
    @adminb.save!
    expect(calculator.calculate(@adminb)).to eql(5.08593)
    # An older Support Facility
    @adminb.manufacture_year = Date.today.year - 19
    @adminb.save!
    expect(calculator.calculate(@adminb)).to eql(3.332)
    # An even older Support Facility
    @adminb.manufacture_year = Date.today.year - 24
    @adminb.save!
    expect(calculator.calculate(@adminb)).to eql(3.14936061952998)
  end

end
