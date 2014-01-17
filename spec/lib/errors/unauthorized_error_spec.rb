require "spec_helper"

describe UnauthorizedError do
  it "should exist" do
    expect { defined?(UnauthorizedError) }.to be_true
  end
  it "should be a subclass of CalcentralError" do
    expect(UnauthorizedError.superclass).to eq ClientError
  end
end
