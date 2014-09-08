require 'spec_helper'

describe Notifications::RegBlockCodeTranslator do
  it "should be able to handle unknown reason_code and/or office_code during translation" do
    result = Notifications::RegBlockCodeTranslator.new().translate_bearfacts_proxy("foo", "baz")
    result[:office].should == "Bearfacts"
    result[:reason].should == "Unknown"
    result[:type].should == "Unknown"
  end

  it "should be able to handle known reason_codes and/or office_code during translation" do
    translator = Notifications::RegBlockCodeTranslator.new()
    result = translator.translate_bearfacts_proxy("60", "BUSADM  ")
    result[:office].should == "Business Administration"
    result[:reason].should == "Academic"
    result[:type].should == "Academic"
    result = translator.translate_bearfacts_proxy("46", "  OR")
    result[:office].should == "Office of the Registrar - Registration"
    result[:reason].should == "Education Abroad"
    result[:type].should == "Administrative"
    result = translator.translate_bearfacts_proxy("70", "LNS")
    result[:office].should == "College of Letters and Science"
    result[:reason].should == "Double Major"
    result[:type].should == "Academic"
  end

  it 'deals with leading zeroes' do
    result = subject.translate_bearfacts_proxy('08', 'LIBRARY')
    expect(result[:office]).to eq 'Library'
    expect(result[:reason]).to eq 'Library Fine'
    expect(result[:type]).to eq 'Financial'
    expect(result[:message]).to include('blocked by the Library')
  end

end
