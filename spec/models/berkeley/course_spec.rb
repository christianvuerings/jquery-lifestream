require "spec_helper"

describe Berkeley::Course do
  let(:course_id) { "compsci-9a-2014-D" }
  subject { Berkeley::Course.new(:course_id => course_id) }
  its(:course_id) { should eq course_id }
end
