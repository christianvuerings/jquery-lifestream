require "spec_helper"

describe Rosters::Common do

  let(:teacher_login_id) { rand(99999).to_s }
  let(:course_id) { rand(99999) }
  let(:section_id) { rand(99999).to_s }
  let(:fake_feed) do
    {
      :sections => [{ :id => section_id, :name => 'COMPSCI 9G SLF 001' }],
      :students => [
        {
          :enroll_status => 'E',
          :id => '9016',
          :login_id => '789124',
          :student_id => '289017',
          :first_name => 'Jack',
          :last_name => 'Nicholson',
          :email => 'jnicholson@example.com',
          :sections => [{:id => section_id}],
          :photo => "/canvas/1/photo/9016",
          :photo_bytes => "8203.0",
          :profile_url => "http://example.com/courses/733/users/9016",
        }
      ]
    }
  end

  describe '#get_feed_filtered' do
    before { allow_any_instance_of(Rosters::Common).to receive(:get_feed_internal).and_return(fake_feed) }
    it 'should return feed without student email addresses' do
      model = Rosters::Common.new(teacher_login_id, course_id: course_id)
      feed = model.get_feed_filtered
      feed[:students].length.should == 1
      expect(feed[:students][0].has_key?(:email)).to eq false
    end
  end
end
