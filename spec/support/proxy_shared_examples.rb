# Proxy Shared Examples
# Used to provide test functionality that is shared across proxy tests.

shared_context 'expecting logs from server errors' do
  before(:each) do
    expect(Rails.logger).to receive(:error) do |error_message|
      lines = error_message.lines.to_a
      expect(lines[0]).to match(/url: http/)
      expect(lines[0]).to match(/status: #{status}/)
      expect(lines[1]).to match(/Associated key:/)
      expect(lines[1]).to match(/uid: #{uid}/) if defined? uid
      expect(lines[1]).to match(/Response body: #{body}/) if defined? body
    end
  end
end

shared_examples 'a proxy logging errors' do
  let! (:body) { 'An unknown error occurred.' }
  let! (:status) { 506 }
  include_context 'expecting logs from server errors'
  before(:each) { stub_request(:any, /.*/).to_return(status: status, body: body) }

  it 'logs errors' do
    subject
  end
end

shared_examples 'a student data proxy' do
  def fake_proxy(uid); proxy_class.new({user_id: uid, fake: true}); end
  def real_proxy(uid); proxy_class.new({user_id: uid, fake: false}); end

  def expect_feed(response, key)
    expect(response).to be_present
    if key
      expect(response[:feed][key]).to be_present
    end
  end

  it 'should get fake data for Oski' do
    response = fake_proxy('61889').get
    expect_feed(response, feed_key)
  end

  it 'should fail gracefully when student ID cannot be found' do
    response = fake_proxy('0').get
    expect(response[:noStudentId]).to eq true
    expect(response[:feed]).to be_nil
  end

  context 'connection failure' do
    before(:each) { stub_request(:any, /.*/).to_raise(Errno::EHOSTUNREACH) }
    after(:each) { WebMock.reset! }
    it 'returns an error status and a nil feed' do
      response = real_proxy('61889').get
      expect(response[:errored]).to eq true
      expect(response[:feed]).to be_nil
    end
  end

  context 'server error' do
    let! (:uid) { '61889' }
    let! (:body) { 'An unknown error occurred.' }
    let! (:status) { 506 }
    include_context 'expecting logs from server errors'

    before(:each) { stub_request(:any, /.*/).to_return(status: status, body: body) }

    it 'returns an error status' do
      response = real_proxy(uid).get
      expect(response[:errored]).to eq true
    end
  end
end
