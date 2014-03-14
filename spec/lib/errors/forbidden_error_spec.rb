require "spec_helper"

describe Errors::ForbiddenError do
  it "should exist" do
    expect { defined?(Errors::ForbiddenError) }.to be_true
  end
  it "should be a subclass of CalcentralError" do
    expect(Errors::ForbiddenError.superclass).to eq Errors::ClientError
  end
end
