require "spec_helper"

describe Errors::UnauthorizedError do
  it "should exist" do
    expect { defined?(Errors::UnauthorizedError) }.to be_true
  end
  it "should be a subclass of CalcentralError" do
    expect(Errors::UnauthorizedError.superclass).to eq Errors::ClientError
  end
end
