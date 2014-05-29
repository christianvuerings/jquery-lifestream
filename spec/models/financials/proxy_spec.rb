require 'spec_helper'

describe Financials::Proxy do

  # We might consider extracting this tricky cache-checker to a shared context.
  before do
    # The usual "let" will not work here.
    @cached_count = 0
    allow(Rails.cache).to receive(:write) do |key, arg1, arg2|
      @cached_count += 1 if key.include? described_class.name
    end
  end

  shared_examples 'has some minimal oski data' do
    it 'should have a body' do
      expect(subject[:body]).to be
    end
    it 'should have a 200 status' do
      expect(subject[:statusCode]).to eq 200
      expect(@cached_count).to be > 0
    end
    it 'should have an apiVersion field' do
      expect(subject[:apiVersion]).to be_a(String)
    end
    it 'should have a student field' do
      expect(subject[:body]['student']).to be
    end
    it 'should have a summary field' do
      expect(subject[:body]['student']['summary']).to be
    end
    it 'should have an accountBalance' do
      expect(subject[:body]['student']['summary']['accountBalance']).to be_a(Numeric)
    end
    it 'should have a minimumAmountDue' do
      expect(subject[:body]['student']['summary']['minimumAmountDue']).to be_a(Numeric)
    end
    it 'should have a minimumAmountDueDate' do
      expect(Date.parse(subject[:body]['student']['summary']['minimumAmountDueDate'])).to be_a(Date)
    end
    it 'should have a isOnDPP field' do
      expect(subject[:body]['student']['summary']['isOnDPP']).to satisfy { |val|
        val.is_a?(TrueClass) || val.is_a?(FalseClass)
      }
    end
  end

  context 'when a student whose data is missing gets the feed' do
    subject { Financials::Proxy.new({user_id: '300940', fake: true}).get }
    it 'should return a specific error message explaining the missing data' do
      expect(subject[:body]).to eq("You are seeing this message because CalCentral does not have CARS billing data for your account. If you are a new student, your account may not have been assessed charges yet. Please try again later. Current or former students should contact us for further assistance using the Feedback link below.")
    end
    it 'should return a 404 status' do
      expect(subject[:statusCode]).to eq(404)
      expect(@cached_count).to be > 0
    end
  end

  context 'when a non-student calls the proxy' do
    subject { Financials::Proxy.new({user_id: '212377'}).get }
    it 'should return a specific error message explaining that non-students lack financials' do
      expect(subject[:body]).to eq("You are seeing this message because CalCentral does not have CARS billing data for your account. If you are a new student, your account may not have been assessed charges yet. Please try again later. Current or former students should contact us for further assistance using the Feedback link below.")
    end
    it 'should return a 400 status' do
      expect(subject[:statusCode]).to eq(400)
      expect(@cached_count).to be > 0
    end
  end

  context 'when Oski gets his fake pre-recorded feed' do
    subject { Financials::Proxy.new({user_id: '61889', fake: true}).get }
    it_behaves_like 'has some minimal oski data'
    it 'should have a specific futureActivity sum' do
      expect(subject[:body]['student']['summary']['futureActivity']).to eq 25.0
      expect(@cached_count).to be > 0
    end
  end

  context 'when working with a real live proxy' do
    subject { Financials::Proxy.new({user_id: '61889'}).get }
    context 'when Oski gets his feed', testext: true do
      it_behaves_like 'has some minimal oski data'
      it 'has a specific apiVersion field' do
        expect(subject[:apiVersion]).to be >= '1.0.6'
      end
    end

    context 'when simulated remote errors occur' do
      include_context 'short-lived cache write of Hash on failures'
      after { WebMock.reset! }

      context 'when remote server is unreachable (connection refused)' do
        before {
          stub_request(:any, /#{Regexp.quote(Settings.financials_proxy.base_url)}.*/).to_raise(Errno::ECONNREFUSED)
        }

        it 'should have a descriptive error message' do
          expect(subject[:body]).to eq('My Finances is currently unavailable. Please try again later.')
        end
        it 'should have a 503 status' do
          expect(subject[:statusCode]).to eq 503
          expect(@cached_count).to eq 1
        end
      end

      context 'when remote server has a 4xx error' do
        before {
          stub_request(:any, /#{Regexp.quote(Settings.financials_proxy.base_url)}.*/).to_return(status: 403)
        }
        it 'should have a descriptive error message' do
          expect(subject[:body]).to eq('My Finances is currently unavailable. Please try again later.')
        end
        it 'should have a 403 status' do
          expect(subject[:statusCode]).to eq 403
          expect(@cached_count).to eq 1
        end
      end
    end
  end
end
