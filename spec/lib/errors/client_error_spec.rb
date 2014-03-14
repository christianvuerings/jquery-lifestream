require "spec_helper"

describe Errors::ClientError do
  it "should exist" do
    expect { defined?(Errors::ClientError) }.to be_true
  end
end
