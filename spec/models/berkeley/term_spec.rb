require "spec_helper"

describe Berkeley::Term do
  subject {Berkeley::Term.new(db_row)}
  context 'Summer Sessions' do
    let(:db_row) {{
      'term_yr' => '2014',
      'term_cd' => 'C',
      'term_status' => 'CS',
      'term_status_desc' => 'Current Summer',
      'term_name' => 'Summer',
      'term_start_date' => Time.gm(2014, 5, 27),
      'term_end_date' => Time.gm(2014, 8, 15)
    }}
    its(:slug) {should eq 'summer-2014'}
    its(:year) {should eq 2014}
    its(:code) {should eq 'C'}
    its(:name) {should eq 'Summer'}
    its(:is_summer) {should eq true}
    its(:sis_term_status) {should eq 'CS'}
    its(:classes_start) {should eq Time.zone.parse('2014-05-27 00:00:00').to_datetime}
    its(:classes_end) {should eq Time.zone.parse('2014-08-15 23:59:59').to_datetime}
    its(:instruction_end) {should eq Time.zone.parse('2014-08-15 23:59:59').to_datetime}
    its(:start) {should eq Time.zone.parse('2014-05-27 00:00:00').to_datetime}
    its(:end) {should eq Time.zone.parse('2014-08-15 23:59:59').to_datetime}
    its(:to_english) {should eq 'Summer 2014'}
  end
  context 'Fall' do
    let(:db_row) {{
      'term_yr' => '2014',
      'term_cd' => 'D',
      'term_status' => 'FT',
      'term_status_desc' => 'Future Term',
      'term_name' => 'Fall',
      'term_start_date' => Time.gm(2014, 8, 28),
      'term_end_date' => Time.gm(2014, 12, 12)
    }}
    its(:slug) {should eq 'fall-2014'}
    its(:year) {should eq 2014}
    its(:code) {should eq 'D'}
    its(:name) {should eq 'Fall'}
    its(:is_summer) {should eq false}
    its(:sis_term_status) {should eq 'FT'}
    its(:classes_start) {should eq Time.zone.parse('2014-08-28 00:00:00').to_datetime}
    its(:classes_end) {should eq Time.zone.parse('2014-12-05 23:59:59').to_datetime}
    its(:instruction_end) {should eq Time.zone.parse('2014-12-12 23:59:59').to_datetime}
    its(:start) {should eq Time.zone.parse('2014-08-21 00:00:00').to_datetime}
    its(:end) {should eq Time.zone.parse('2014-12-19 23:59:59').to_datetime}
    its(:to_english) {should eq 'Fall 2014'}
  end
  context 'Spring' do
    let(:db_row) {{
      'term_yr' => '2014',
      'term_cd' => 'B',
      'term_status' => 'CT',
      'term_status_desc' => 'Current Term',
      'term_name' => 'Spring',
      'term_start_date' => Time.gm(2014, 1, 21),
      'term_end_date' => Time.gm(2014, 5, 9)
    }}
    its(:slug) {should eq 'spring-2014'}
    its(:year) {should eq 2014}
    its(:code) {should eq 'B'}
    its(:name) {should eq 'Spring'}
    its(:is_summer) {should eq false}
    its(:sis_term_status) {should eq 'CT'}
    its(:classes_start) {should eq Time.zone.parse('2014-01-21 00:00:00').to_datetime}
    its(:classes_end) {should eq Time.zone.parse('2014-05-02 23:59:59').to_datetime}
    its(:instruction_end) {should eq Time.zone.parse('2014-05-09 23:59:59').to_datetime}
    its(:start) {should eq Time.zone.parse('2014-01-14 00:00:00').to_datetime}
    its(:end) {should eq Time.zone.parse('2014-05-16 23:59:59').to_datetime}
    its(:to_english) {should eq 'Spring 2014'}
  end

end
