require 'spec_helper'

describe Finaid::MyBudget do

  subject { feed = {}; Finaid::MyBudget.new(61889).append_feed!(feed); feed }

  it 'should return some budget items' do
    expect(subject[:finaidBudget]).to be
    expect(subject[:finaidBudget][:terms][0][:items][0]).to be
    expect(subject[:finaidBudget][:terms][0][:items][0][:title]).to eq 'Base Tuition'
    expect(subject[:finaidBudget][:terms][0][:items][0][:amount]).to eq 6402
    expect(subject[:finaidBudget][:terms][0][:startTerm]).to eq 'Fall'
    expect(subject[:finaidBudget][:terms][0][:startTermYear]).to eq '2014'
    expect(subject[:finaidBudget][:terms][0][:endTerm]).to eq 'Spring'
    expect(subject[:finaidBudget][:terms][0][:endTermYear]).to eq '2015'
    expect(subject[:finaidBudget][:terms][0][:budgetTotal]).to eq 27116
  end

end
