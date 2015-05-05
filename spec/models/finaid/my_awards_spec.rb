require 'spec_helper'

describe Finaid::MyAwards do

  subject { feed = {}; Finaid::MyAwards.new(61889).append_feed!(feed); feed }

  it 'should return some awards' do
    expect(subject[:finaidAwards]).to be
    expect(subject[:finaidAwards][:terms][0][:categories][0]).to be
    expect(subject[:finaidAwards][:terms][0][:categories][0][:title]).to eq 'Grant'
    expect(subject[:finaidAwards][:terms][0][:categories][1][:title]).to eq 'Loan'
    expect(subject[:finaidAwards][:terms][0][:categories][0][:items]).to be
    expect(subject[:finaidAwards][:terms][0][:categories][0][:items][0][:title]).to eq 'Jon Q. Reynolds Scholarship'
    expect(subject[:finaidAwards][:terms][0][:categories][0][:total]).to eq 6500
    expect(subject[:finaidAwards][:terms][0][:categories][1][:total]).to eq 5500
    expect(subject[:finaidAwards][:terms][0][:totalOffered]).to eq 12000
    expect(subject[:finaidAwards][:terms][0][:totalAccepted]).to eq 6500
    expect(subject[:finaidAwards][:terms][0][:startTerm]).to eq 'Fall'
    expect(subject[:finaidAwards][:terms][0][:startTermYear]).to eq '2014'
    expect(subject[:finaidAwards][:terms][0][:endTerm]).to eq 'Spring'
    expect(subject[:finaidAwards][:terms][0][:endTermYear]).to eq '2015'
  end

end
