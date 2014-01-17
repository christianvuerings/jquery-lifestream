require "spec_helper"

describe ForbiddenError do
  it "should exist" do
    expect { defined?(ForbiddenError) }.to be_true
  end
  it "should be a subclass of CalcentralError" do
    expect(ForbiddenError.superclass).to eq ClientError
  end
end
