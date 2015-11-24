require 'rails_helper'

RSpec.describe Role, :type => :model do
  it '.to_s' do
    expect(Role.first.to_s).to eq(Role.first.name)
  end

  it '.privilege?' do
    expect(Role.where('privilege = false').first.privilege?).to be false
    expect(Role.where('privilege = true').first.privilege?).to be true
  end
end
