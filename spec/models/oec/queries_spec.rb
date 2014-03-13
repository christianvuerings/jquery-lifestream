require "spec_helper"

describe Oec::Queries do

  context "looking up students" do
    subject { Oec::Queries.get_all_students(["11684"]) }
    it { should_not be_nil }
    unless Oec::Queries.test_data?
      it { subject[0]["ldap_uid"].should_not be_nil }
    end
  end

  context "looking up instructors" do
    subject { Oec::Queries.get_all_instructors(["11684"]) }
    it { should_not be_nil }
    unless Oec::Queries.test_data?
      it { subject[0]["ldap_uid"].should_not be_nil }
    end
  end

  context "looking up courses", :testext => true do
    subject { Oec::Queries.get_all_courses }
    it { should_not be_nil }
    unless Oec::Queries.test_data?
      it { subject[0]["course_id"].should_not be_nil }
    end
  end

  context "looking up course_instructors" do
    subject { Oec::Queries.get_all_course_instructors(["11684"]) }
    it { should_not be_nil }
    unless Oec::Queries.test_data?
      it { subject[0]["ldap_uid"].should_not be_nil }
    end
  end

  context "looking up course_students" do
    subject { Oec::Queries.get_all_course_students(["11684"]) }
    it { should_not be_nil }
    unless Oec::Queries.test_data?
      it { subject[0]["ldap_uid"].should_not be_nil }
    end
  end
end
