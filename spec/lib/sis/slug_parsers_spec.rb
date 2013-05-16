require 'spec_helper'

describe 'SlugParsers' do

  it 'should parse properly formatted section slugs' do
    result = SIS::SlugParsers.parse_section_slug 'SEC:2012-D-26193'
    result.is_a?(Hash).should be_true
    result[:year].should == '2012'
    result[:term_cd].should == 'D'
    result[:ccn].should == '26193'
  end

  it 'should throw Argument Errors on bad section slugs' do
    expect{ SIS::SlugParsers.parse_section_slug 'SEC:2012-derp'}.to raise_error(ArgumentError)
    expect{ SIS::SlugParsers.parse_section_slug ''}.to raise_error(ArgumentError)
    expect{ SIS::SlugParsers.parse_section_slug 'LEC:2012-D-26193'}.to raise_error(ArgumentError)
  end
end