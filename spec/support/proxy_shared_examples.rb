# Proxy Shared Examples
# Used to provide test functionality that is shared across proxy tests.

shared_examples 'a student data proxy' do
  def fake_proxy(uid); proxy_class.new({user_id: uid, fake: true}); end
  def real_proxy(uid); proxy_class.new({user_id: uid, fake: false}); end

  def expect_feed(response, key)
    expect(response).to be_present
    if key
      expect(response[:feed][key]).to be_present
    end
  end

  it 'should get Oski data from fake vcr recordings' do
    response = fake_proxy('61889').get
    expect_feed(response, feed_key)
  end

  it 'should fail gracefully when student ID cannot be found' do
    response = fake_proxy('0').get
    expect(response[:noStudentId]).to eq true
    expect(response[:feed]).to be_nil
  end

  it 'should get Oski data from real server', :testext => true do
    response = real_proxy('61889').get
    expect(response).to be_present
  end

  context 'connection failure' do
    before(:each) { stub_request(:any, /#{Regexp.quote(Settings.bearfacts_proxy.base_url)}.*/).to_raise(Errno::EHOSTUNREACH) }
    after(:each) { WebMock.reset! }
    it 'returns an error status and a nil feed' do
      response = real_proxy('61889').get
      expect(response[:errored]).to eq true
      expect(response[:feed]).to be_nil
    end
  end
end
