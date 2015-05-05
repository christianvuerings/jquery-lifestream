require 'spec_helper'

describe Finaid::MyAwards do

  subject { feed = {}; Finaid::MyAwards.new(61889).append_feed!(feed); feed }

  it 'should return some awards' do
    expect(subject[:finaidAwards]).to be
    expect(subject[:finaidAwards][:terms]['2015'][:categories]['Grant']).to be
    expect(subject[:finaidAwards][:terms]['2015'][:categories]['Grant'][:items]).to be
    expect(subject[:finaidAwards][:terms]['2015'][:categories]['Grant'][:items][0][:title]).to eq 'Jon Q. Reynolds Scholarship'
    expect(subject[:finaidAwards][:terms]['2015'][:categories]['Grant'][:total]).to eq 6500
    expect(subject[:finaidAwards][:terms]['2015'][:categories]['Loan'][:total]).to eq 5500
    expect(subject[:finaidAwards][:terms]['2015'][:totalOffered]).to eq 12000
    expect(subject[:finaidAwards][:terms]['2015'][:totalAccepted]).to eq 6500
    expect(subject[:finaidAwards][:terms]['2015'][:startTerm]).to eq 'Fall'
    expect(subject[:finaidAwards][:terms]['2015'][:startTermYear]).to eq '2014'
    expect(subject[:finaidAwards][:terms]['2015'][:endTerm]).to eq 'Spring'
    expect(subject[:finaidAwards][:terms]['2015'][:endTermYear]).to eq '2015'
  end

end
