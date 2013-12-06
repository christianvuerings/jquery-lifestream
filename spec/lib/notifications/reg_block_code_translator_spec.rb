require 'spec_helper'

describe RegBlockCodeTranslator do
  it "should be able to handle unknown reason_code and/or office_code during translation" do
    result = RegBlockCodeTranslator.new().translate_bearfacts_proxy("foo", "baz")
    result[:office].should == "Bearfacts"
    result[:reason].should == "Unknown"
    result[:type].should == "Unknown"
  end

  it "should be able to handle known reason_codes and/or office_code during translation" do
    translator = RegBlockCodeTranslator.new()
    result = translator.translate_bearfacts_proxy("60", "BUSADM  ")
    result[:office].should == "Business Administration"
    result[:reason].should == "Academic"
    result[:type].should == "Academic"
    result = translator.translate_bearfacts_proxy("46", "  OR")
    result[:office].should == "Office of the Registrar - Registration"
    result[:reason].should == "Education Abroad"
    result[:type].should == "Administrative"
  end


end
