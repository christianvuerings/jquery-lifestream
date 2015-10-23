describe Rosters::Common do

  let(:teacher_login_id) { rand(99999).to_s }
  let(:course_id) { rand(99999) }
  let(:section_id_one) { rand(99999).to_s }
  let(:section_id_two) { rand(99999).to_s }
  let(:section_id_three) { rand(99999).to_s }
  let(:fake_feed) do
    {
      :sections => [
        {:ccn => section_id_one, :name => 'COMPSCI 9G SLF 001'},
        {:ccn => section_id_two, :name => 'COMPSCI 9G SLF 002'},
        {:ccn => section_id_three, :name => 'COMPSCI 9G SLF 003'},
      ],
      :students => [
        {
          :enroll_status => 'E',
          :id => '9016',
          :login_id => '789124',
          :student_id => '289017',
          :first_name => 'Jack',
          :last_name => 'Nicholson',
          :email => 'jnicholson@example.com',
          :sections => [
            {:ccn => section_id_one, :name => 'COMPSCI 9G SLF 001'}
          ],
          :photo => '/canvas/1/photo/9016',
          :photo_bytes => '8203.0',
          :profile_url => 'http://example.com/courses/733/users/9016',
        },
        {
          :enroll_status => 'W',
          :id => '9017',
          :login_id => '789125',
          :student_id => '289018',
          :first_name => 'Seth',
          :last_name => 'Rogen',
          :email => 'srogen@example.com',
          :sections => [
            {:ccn => section_id_one, :name => 'COMPSCI 9G SLF 001'},
            {:ccn => section_id_two, :name => 'COMPSCI 9G SLF 002'}
          ],
          :photo => '/canvas/1/photo/9017',
          :photo_bytes => '9203.1',
          :profile_url => 'http://example.com/courses/733/users/9017',
        },
        {
          :enroll_status => 'C',
          :id => '9018',
          :login_id => '789164',
          :student_id => '289019',
          :first_name => 'Michael',
          :last_name => 'Fox',
          :email => 'mfox@example.com',
          :sections => [
            {:ccn => section_id_three, :name => 'COMPSCI 9G SLF 003'}
          ],
          :photo => '/canvas/1/photo/9018',
          :photo_bytes => '7802.0',
          :profile_url => 'http://example.com/courses/733/users/9018',
        },
      ]
    }
  end
  subject { Rosters::Common.new(teacher_login_id, course_id: course_id) }

  context 'when serving roster feed based content' do
    before { allow_any_instance_of(Rosters::Common).to receive(:get_feed_internal).and_return(fake_feed) }

    describe '#get_feed_filtered' do
      it 'should return feed without student email addresses' do
        feed = subject.get_feed_filtered
        feed[:students].length.should == 3
        expect(feed[:students][0].has_key?(:email)).to eq false
        expect(feed[:students][1].has_key?(:email)).to eq false
        expect(feed[:students][2].has_key?(:email)).to eq false
      end
    end

    describe '#get_csv' do
      it "returns rosters csv" do
        rosters_csv_string = subject.get_csv
        expect(rosters_csv_string).to be_an_instance_of String
        rosters_csv = CSV.parse(rosters_csv_string, {headers: true})
        expect(rosters_csv.count).to eq 3

        expect(rosters_csv[0]).to be_an_instance_of CSV::Row
        expect(rosters_csv[0]['Name']).to eq 'Nicholson, Jack'
        expect(rosters_csv[0]['User ID']).to eq '789124'
        expect(rosters_csv[0]['Student ID']).to eq '289017'
        expect(rosters_csv[0]['Email Address']).to eq 'jnicholson@example.com'
        expect(rosters_csv[0]['Role']).to eq 'Student'
        expect(rosters_csv[0]['Sections']).to eq 'COMPSCI 9G SLF 001'

        expect(rosters_csv[1]).to be_an_instance_of CSV::Row
        expect(rosters_csv[1]['Name']).to eq 'Rogen, Seth'
        expect(rosters_csv[1]['User ID']).to eq '789125'
        expect(rosters_csv[1]['Student ID']).to eq '289018'
        expect(rosters_csv[1]['Email Address']).to eq 'srogen@example.com'
        expect(rosters_csv[1]['Role']).to eq 'Waitlist Student'
        expect(rosters_csv[1]['Sections']).to eq 'COMPSCI 9G SLF 001, COMPSCI 9G SLF 002'

        expect(rosters_csv[2]).to be_an_instance_of CSV::Row
        expect(rosters_csv[2]['Name']).to eq 'Fox, Michael'
        expect(rosters_csv[2]['User ID']).to eq '789164'
        expect(rosters_csv[2]['Student ID']).to eq '289019'
        expect(rosters_csv[2]['Email Address']).to eq 'mfox@example.com'
        expect(rosters_csv[2]['Role']).to eq 'Concurrent Student'
        expect(rosters_csv[2]['Sections']).to eq 'COMPSCI 9G SLF 003'
      end
    end
  end

  describe '#index_by_attribute' do
    it 'returns hash of arrays indexed by item attributes' do
      sections = [
        {:ccn => 123, :name => 'Course with CCN 123'},
        {:ccn => 124, :name => 'Course with CCN 124'},
        {:ccn => 125, :name => 'Course with CCN 125'},
      ]
      result = subject.index_by_attribute(sections, :ccn)
      expect(result).to be_an_instance_of Hash
      expect(result.keys).to eq [123, 124, 125]
      expect(result[123]).to eq sections[0]
      expect(result[124]).to eq sections[1]
      expect(result[125]).to eq sections[2]
    end
  end

  describe '#sections_to_name_string' do
    it 'returns section names in string format' do
      sections = [
        {:ccn => 123, :name => 'Course with CCN 123'},
        {:ccn => 124, :name => 'Course with CCN 124'},
      ]
      result = subject.sections_to_name_string([sections[0]])
      expect(result).to eq "Course with CCN 123"
      result = subject.sections_to_name_string([sections[1]])
      expect(result).to eq "Course with CCN 124"
      result = subject.sections_to_name_string(sections)
      expect(result).to eq "Course with CCN 123, Course with CCN 124"
    end
  end

end
