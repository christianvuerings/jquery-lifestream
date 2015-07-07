require "spec_helper"

describe PingController do


    context 'User database unavailable' do
      before do
        User::Data.stub(:database_alive?).and_return(false)
        CampusOracle::Queries.stub(:database_alive?).and_return(true)
      end
      it 'raises error' do
        get :do
        expect {raise 'CalCentral database is currently unavailable'}.to raise_error('CalCentral database is currently unavailable')
        expect(response.status).to eq 503
      end
    end

    context 'Campus database unavailable' do
      before do
        User::Data.stub(:database_alive?).and_return(true)
        CampusOracle::Queries.stub(:database_alive?).and_return(false)
      end
      it 'raises error' do
        get :do
        expect {raise 'Campus database is currently unavailable'}.to raise_error('Campus database is currently unavailable')
        expect(response.status).to eq 503
      end
    end

    context 'Both databases unavailable' do
      before do
        User::Data.stub(:database_alive?).and_return(false)
        CampusOracle::Queries.stub(:database_alive?).and_return(false)
      end
      it 'raises error' do
        get :do
        expect {raise 'CalCentral database is currently unavailable'}.to raise_error('CalCentral database is currently unavailable')
        expect(response.status).to eq 503
      end
    end


    context 'Both databases available' do
      before do
        User::Data.stub(:database_alive?).and_return(true)
        CampusOracle::Queries.stub(:database_alive?).and_return(true)
      end

      context 'do not do background jobs check' do
        before do
          Settings.features.stub(:background_jobs_check).and_return(false)
          @expected = { :server_alive => true }.to_json
        end
        it 'renders a json file with server status' do
          get :do
          response.body.should == @expected
        end
      end

      context 'do background jobs check' do
        before do
          Settings.features.stub(:background_jobs_check).and_return(true)
          @example_backgroundjobscheck = { :"ets-calcentral-prod-01" => "OK", :"ets-calcentral-prod-02" => "OK",:"ets-calcentral-prod-03" => "OK",:"status" => "OK","last_ping" => "2015-07-06T16:31:50.161-07:00"}.to_json
          BackgroundJobsCheck.any_instance.stub(:get_feed => @example_backgroundjobscheck)
          @expected = { :server_alive => true, :background_jobs_check => @example_backgroundjobscheck }.to_json
        end
        it 'renders a json file with server status and background jobs' do
          get :do
          response.body.should == @expected
        end
      end
    end
end
