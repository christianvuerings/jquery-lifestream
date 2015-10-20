describe Regstatus::Proxy do

  it_should_behave_like 'a student data proxy' do
    let(:proxy_class) { Regstatus::Proxy }
    let(:feed_key) { 'regStatus' }
  end

  context 'mock proxy' do
    let(:oski_uid) { '61889' }
    let(:oski_student_id) { 11667051 }
    let(:fake_proxy) { Regstatus::Proxy.new(user_id: oski_uid, fake: true) }
    let(:feed) { fake_proxy.get[:feed] }

    it 'returns JSON fixture data by default' do
      expect(feed['regStatus']['isRegistered']).to eq true
      expect(feed['regStatus']['studentId']).to eq oski_student_id
      expect(feed['regStatus']['termName']).to eq 'Fall'
      expect(feed['regStatus']['termYear']).to eq 2013
    end

    it 'can be overridden selectively' do
      fake_proxy.override_json { |json| json['regStatus']['isRegistered'] = false }
      expect(feed['regStatus']['isRegistered']).to eq false
      expect(feed['regStatus']['studentId']).to eq oski_student_id
      expect(feed['regStatus']['termName']).to eq 'Fall'
      expect(feed['regStatus']['termYear']).to eq 2013
    end

    it 'can be overridden with variable data' do
      current_term = Berkeley::Terms.fetch.current
      fake_proxy.override_json do |json|
        json['regStatus']['termName'] = current_term.name
        json['regStatus']['termYear'] = current_term.year
      end
      expect(feed['regStatus']['termName']).to eq current_term.name
      expect(feed['regStatus']['termYear']).to eq current_term.year
    end

    it 'can be overridden to return errors' do
      fake_proxy.set_response(status: 506, body: '')
      response = fake_proxy.get
      expect(response[:errored]).to eq true
    end

    it 'can selectively override data based on request parameters' do
      fake_proxy.on_request(query: hash_including(termYear: '2014')).override_json do |json|
        json['regStatus']['termYear'] = 2014
        json['regStatus']['isRegistered'] = false
      end

      current_feed = fake_proxy.get[:feed]
      expect(current_feed['regStatus']['termYear']).to eq 2013
      expect(current_feed['regStatus']['isRegistered']).to eq true

      spring_2014 = Berkeley::Terms.fetch.campus['spring-2014']
      future_feed = fake_proxy.get(spring_2014)[:feed]
      expect(future_feed['regStatus']['termYear']).to eq 2014
      expect(future_feed['regStatus']['isRegistered']).to eq false
    end

  end
end
