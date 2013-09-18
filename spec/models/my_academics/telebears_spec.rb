require 'spec_helper'

describe MyAcademics::Telebears do
  let(:oski_uid){ "61889" }
  let(:non_student_uid) { '212377' }
  let(:fake_oski_feed) { BearfactsTelebearsProxy.new({:user_id => "61889", :fake => true}).get }

  shared_examples "empty telebears response" do
    it { should_not be_empty }
    its([:foo]) { should eq('baz') }
    its([:telebears]) { should be_empty }
  end

  context "dead remote proxy (5xx errors)" do
    before(:each) { stub_request(:any, /#{Regexp.quote(Settings.bearfacts_proxy.base_url)}.*/).to_raise(Faraday::Error::ConnectionFailed) }
    after(:each) { WebMock.reset! }

    subject { MyAcademics::Telebears.new(oski_uid).merge(@feed ||= {foo: 'baz'}); @feed }

    it_behaves_like "empty telebears response"
  end

  context "4xx response from bearfacts proxy with non-student" do
    before(:each) { BearfactsTelebearsProxy.any_instance.stub(:get_feed).and_return({}) }

    subject { MyAcademics::Telebears.new(non_student_uid).merge(@feed ||= {foo: 'baz'}); @feed }

    it_behaves_like "empty telebears response"
  end

  context "2xx reponses with fake oski" do
    before(:each) { BearfactsTelebearsProxy.any_instance.stub(:get_feed).and_return(fake_oski_feed) }
  end
end