require 'spec_helper'

describe Canvas::CourseAssignments do

  let(:user_id)             { 2050 }
  let(:canvas_course_id)    { 1234001 }
  subject                   { Canvas::CourseAssignments.new(:course_id => canvas_course_id) }

  it 'provides course assignments' do
    assignments = subject.course_assignments
    expect(assignments).to be_an_instance_of Array
    expect(assignments.count).to eq 2
    expect(assignments[0]['id']).to eq 6175848
    expect(assignments[0]['name']).to eq 'Assignment 1'
    expect(assignments[0]['description']).to eq '<p>Assignment 1 description</p>'
    expect(assignments[0]['muted']).to eq false
    expect(assignments[0]['due_at']).to eq "2015-05-12T19:40:00Z"
    expect(assignments[0]['points_possible']).to eq 100

    expect(assignments[1]['id']).to eq 6175849
    expect(assignments[1]['name']).to eq "Assignment 2"
    expect(assignments[1]['description']).to eq '<p>Assignment 2 description</p>'
    expect(assignments[1]['muted']).to eq true
    expect(assignments[1]['due_at']).to eq nil
    expect(assignments[1]['points_possible']).to eq 50
  end

  context 'when providing muted assignments' do
    let(:fake_assignments) do
      [
        {'id' => 1, 'name' => 'Assignment 1', 'muted' => false},
        {'id' => 2, 'name' => 'Assignment 2', 'muted' => true},
        {'id' => 3, 'name' => 'Assignment 3', 'muted' => false},
      ]
    end
    it 'provides muted course assignments' do
      allow(subject).to receive(:course_assignments).and_return(fake_assignments)
      muted_assignments = subject.muted_assignments
      expect(muted_assignments).to be_an_instance_of Array
      expect(muted_assignments.count).to eq 1
      expect(muted_assignments[0]['id']).to eq 2
      expect(muted_assignments[0]['name']).to eq 'Assignment 2'
    end

    it 'serves uncached records' do
      expect(subject).to receive(:course_assignments).and_return(fake_assignments)
      muted_assignments = subject.muted_assignments
    end
  end

  context 'when unmuting an assignment' do
    it 'unmutes the assignment' do
      request_params = {
        'assignment' => {
          'muted' => false
        }
      }
      request_options = {
        :method => :put,
        :body => request_params,
      }
      result = subject.unmute_assignment(11)
      expect(result).to be_an_instance_of Hash
      expect(result['id']).to eq 11
      expect(result['muted']).to eq false
    end
  end
end
