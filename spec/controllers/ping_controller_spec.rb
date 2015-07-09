require "spec_helper"

describe PingController do

  context 'User database unavailable' do
    before do
      User::Data.stub(:database_alive?).and_return(false)
      CampusOracle::Queries.stub(:database_alive?).and_return(true)
    end
    it 'raises error' do
      expect(Rails.logger).to receive(:fatal)
      get :do
      expect(response.status).to eq 503
    end
  end

  context 'Campus database unavailable' do
    before do
      User::Data.stub(:database_alive?).and_return(true)
      CampusOracle::Queries.stub(:database_alive?).and_return(false)
    end
    it 'raises error' do
      expect(Rails.logger).to receive(:fatal)
      get :do
      expect(response.status).to eq 503
    end
  end

  context 'Both databases unavailable' do
    before do
      User::Data.stub(:database_alive?).and_return(false)
      CampusOracle::Queries.stub(:database_alive?).and_return(false)
    end
    it 'raises error' do
      expect(Rails.logger).to receive(:fatal)
      get :do
      expect(response.status).to eq 503
    end
  end

  context 'Both databases available' do
    before do
      User::Data.stub(:database_alive?).and_return(true)
      CampusOracle::Queries.stub(:database_alive?).and_return(true)
    end

    context 'do not do background jobs check' do
      let (:expected) { { 'server_alive' => true }.to_json }
      before do
        Settings.features.stub(:background_jobs_check).and_return(false)
      end
      it 'renders a json file with server status' do
        get :do
        expect(response.body).to eq expected
      end
    end

    context 'do background jobs check' do
      let (:example_background_jobs_check) { { 'ets-calcentral-prod-01' => 'OK', 'ets-calcentral-prod-02' => 'OK', 'ets-calcentral-prod-03' => 'OK', 'status' => 'OK', 'last_ping' => '2015-07-06T16:31:50.161-07:00'}.to_json }
      let (:expected) { { 'server_alive' => true, 'background_jobs_check' => example_background_jobs_check }.to_json }
      before do
        Settings.features.stub(:background_jobs_check).and_return(true)
        BackgroundJobsCheck.any_instance.stub(:get_feed => example_background_jobs_check)
      end
      it 'renders a json file with server status and background jobs' do
        get :do
        expect(response.body).to eq expected
      end
    end
  end
end
