require 'rails_helper'

RSpec.describe NoticesHelper, :type => :helper do
  let(:notice)  {build_stubbed(:notice)}

  it '#notice_endpoints' do
    notice.display_datetime = DateTime.new(2014, 10, 17, 0)
    notice.end_datetime     = DateTime.new(2014, 10, 17, 10, 30) # 10.5 hours later
    result = "#{notice.display_datetime.strftime('%b %d, %Y %l:%M%p')} - #{notice.end_datetime.strftime('%b %d, %Y %l:%M%p')}"
    expect(notice_endpoints(notice)).to eq(result)
  end

  it '#notice_title' do
    expect(notice_title(notice)).to eq("Test Subject") #if active

    notice.active = false
    expect(notice_title(notice)).to eq("Test Subject<small class='text-danger'> (Inactive)</small>") #if inactive
  end

end
