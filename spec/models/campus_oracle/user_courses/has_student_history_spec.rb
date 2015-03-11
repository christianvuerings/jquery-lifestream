require 'spec_helper'

describe CampusOracle::UserCourses::HasStudentHistory do

  it 'should say that Tammi has student history', :if => CampusOracle::Connection.test_data? do
    client = CampusOracle::UserCourses::HasStudentHistory.new({user_id: '300939'})
    client.has_student_history?.should be_truthy
  end

end
