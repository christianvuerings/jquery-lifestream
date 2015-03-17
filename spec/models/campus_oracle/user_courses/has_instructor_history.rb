require 'spec_helper'

describe CampusOracle::UserCourses::HasInstructorHistory do

  it 'should say that our fake teacher has instructor history', :if => CampusOracle::Connection.test_data? do
    client = CampusOracle::UserCourses::HasInstructorHistory.new({user_id: '238382'})
    client.has_instructor_history?.should be_truthy
  end

end
