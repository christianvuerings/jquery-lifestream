require 'spec_helper'
require 'tempfile'
require 'csv'

describe 'PopulateLectureInstanceEnrollment' do
  before :each do
    @dummy_section_file = Tempfile.new('foo.csv')
    csv = CSV.open(@dummy_section_file.path, 'wb', :headers => true)
    csv << 'canvas_section_id,section_id,canvas_course_id,course_id,name,status,start_date,end_date,canvas_account_id,account_id'.parse_csv
    #not sure why it ignores my first insertion.
    csv << '1,SEC:2013-B-7309,1,COURSE:BIO:1A:2013-B,BIO 1A:Advanced Biology for poets,active,,,1,ACCT:BIO'.parse_csv
    csv << '1,SEC:2013-B-7309,1,COURSE:BIO:1A:2013-B,BIO 1A:Advanced Biology for poets,active,,,1,ACCT:BIO'.parse_csv if ENV['RAILS_ENV'] == 'test'
    csv << '1,SEC:2013-D-54282,1,COURSE:MATH:185:2013-D,MATH 185:Basic Math for botanists,active,,,1,ACCT:MATH'.parse_csv if ENV['RAILS_ENV'] == 'testext'
    csv << '1,SEC:2018-E-1,1,COURSE:MATH:1A:2018-E,MATH 1A:The Abacus returns,active,,,1,ACCT:MATH'.parse_csv
    csv.close
    @temp_dir_path = Dir.mktmpdir
  end

  after :each do
    FileUtils.remove_entry_secure @temp_dir_path
    @dummy_section_file.close unless @dummy_section_file.closed?
    @dummy_section_file.unlink
  end

  it 'should have a successful import' do
    processor = SIS::PopulateLectureInstanceEnrollment.new(@dummy_section_file, @temp_dir_path)
    processor.instance_variable_defined?(:@sections).should be_true
    section = processor.instance_variable_get(:@sections)
    section.headers.should_not be_empty
    processor.instance_variable_defined?(:@output_files).should be_true

    result =  processor.populate_section_enrollments
    result.is_a?(Hash).should be_true
    if ENV['RAILS_ENV'] == 'test'
      result[:added_students].should == 1
      result[:added_enrollments]["SEC:2013-B-7309"].should == 1
    elsif ENV['RAILS_ENV'] == 'testext'
      result[:added_students].should >= 1
      result[:added_enrollments]["SEC:2013-D-54282"].should >= 1
    end
  end
end