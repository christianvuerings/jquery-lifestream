require "spec_helper"

describe Bearfacts::Exams do

  it_should_behave_like 'a student data proxy' do
    let!(:proxy_class) { Bearfacts::Exams }
    let!(:feed_key) { 'studentFinalExamSchedules' }
  end

end
