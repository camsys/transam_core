require 'rails_helper'

RSpec.describe Notice, :type => :model do
  let(:notice)        {build_stubbed(:notice)}
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
  
  describe '.new' do
    it 'validates the correct fields' do
      n = Notice.new(subject: nil, details: nil, notice_type: nil, display_datetime: nil, end_datetime: nil, organization: nil)
      # presence validators
      expect(n).not_to be_valid
      # display- and end_datetime have defaults set, and organization allows nil.  Leaves three invalid fields
      expect(n.errors.count).to be(3) 
    end

    it 'accepts valid virtual attributes' do
      n = Notice.new(subject: "Test", summary: "Summary", notice_type: NoticeType.first, 
        display_datetime_date: "10-17-2014", display_datetime_hour: "15",
        end_datetime_date: "10-17-2014", end_datetime_hour: "16")

      expect(n).to be_valid
      expect(n.display_datetime).to eq(Time.new(2014, 10, 17, 15))
      expect(n.end_datetime).to eq(Time.new(2014, 10, 17, 16))
    end
  end

  #------------------------------------------------------------------------------
  #
  # Scope Methods
  #
  #------------------------------------------------------------------------------
  
  # Scopes are tested by changes, since they require changes to the DB
  describe '.system_level_notices' do
    it 'returns notices with no organization set' do
      expect{
        FactoryGirl.create(:system_notice)
        }.to change{Notice.system_level_notices.count}.by(1)
    end
  end

  describe '.active_for_organizations' do
    it 'returns system notices and organization-specific notices' do
      test_org = create(:organization)
      
      expect{
        FactoryGirl.create(:system_notice)
        FactoryGirl.create(:notice, organization: test_org)
      }.to change{Notice.active_for_organizations([test_org]).count}.by(2) # 1 for system, 1 for organization
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  
  describe '#duration_in_hours' do
    it 'returns a whole number' do
      notice.display_datetime = DateTime.new(2014, 10, 17, 0)
      notice.end_datetime     = DateTime.new(2014, 10, 17, 10, 30) # 10.5 hours later

      expect(notice.duration_in_hours).to be(11)
    end

    it 'can handle simultaneous start and end' do
      notice.display_datetime = DateTime.new(2014, 10, 17, 0)
      notice.end_datetime     = DateTime.new(2014, 10, 17, 0)

      expect(notice.duration_in_hours).to be(0)
    end
  end

  describe '#set_defaults' do
    it 'sets the active, start and stop attributes' do
      n = Notice.new

      expect(n.active).to be(true)
      puts 'DEREK'
      puts n.display_datetime
      puts DateTime.current.beginning_of_hour
      puts n.end_datetime
      puts DateTime.current.end_of_day
      expect(n.display_datetime).to eq(DateTime.current.beginning_of_hour) 
      expect(n.end_datetime).to eq(DateTime.current.end_of_day.change(usec: 0)) #change(usec: 0) rounds down to the nearest second so 23:59:59 instead of 23:59:59.99999 
    end
  end

end
