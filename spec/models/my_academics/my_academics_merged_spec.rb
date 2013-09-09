require "spec_helper"

describe "MyAcademics::Merged" do

  it "should call the merge method on all the Academic submodules" do

    model_classes = [
      MyAcademics::CollegeAndLevel,
      MyAcademics::GpaUnits,
      MyAcademics::Requirements,
      MyAcademics::Regblocks,
      MyAcademics::Semesters,
      MyAcademics::Teaching,
      MyAcademics::Exams
    ]
    model_classes.each do |klass|
      model = klass.new "61889"
      klass.stub(:new).and_return(model)
      klass.stub(:merge).and_return({})
      model.should_receive(:merge)
    end

    MyAcademics::Merged.new("61889").get_feed
  end

end
