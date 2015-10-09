describe OecTasksController do

  before do
    session['user_id'] = random_id
    allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_administer_oec?).and_return true
  end

  shared_examples 'authorization and error handling' do
    it_should_behave_like 'a user authenticated api endpoint'

    context 'when user is not authorized' do
      before { allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_administer_oec?).and_return false }
      it 'should respond with empty http 403' do
        make_request
        expect(response.status).to eq 403
        expect(response.body).to eq ' '
      end
    end
  end

  describe '#index' do
    let(:make_request) { get :index }
    include_examples 'authorization and error handling'

    it 'returns tasks, terms and departments' do
      make_request
      expect(response.status).to eq 200
      response_body = JSON.parse response.body
      expect(response_body['oecDepartments'].count).to be > 2
      expect(response_body['oecTasks'].count).to be > 2
      response_body['oecTasks'].each do |task|
        expect(task['name']).to be_present
        expect(task['friendlyName']).to be_present
        expect(task['htmlDescription']).to be_present
      end
      expect(response_body['oecTerms'].count).to be > 2
    end
  end

  describe '#run' do
    let(:task_id) { Oec::ApiTaskWrapper.generate_task_id }
    let(:task_name) { 'TermSetupTask' }
    let(:term_name) { 'Summer 2013' }
    let(:make_request) { post :run, task_name: task_name, term: term_name }
    include_examples 'authorization and error handling'

    it_should_behave_like 'an api endpoint' do
      before do
        allow_any_instance_of(Oec::ApiTaskWrapper).to receive(:start_in_background).and_raise(RuntimeError, 'Something went wrong')
      end
    end

    it 'should start task wrapper and return status' do
      expect_any_instance_of(Oec::ApiTaskWrapper).to receive(:start_in_background).and_return({
        id: task_id,
        status: 'In progress'
      })
      make_request
      expect(response.status).to eq 200
      response_body = JSON.parse response.body
      expect(response_body['oecDriveUrl']).to eq Oec::RemoteDrive::HUMAN_URL
      expect(response_body['oecTaskStatus']['id']).to eq task_id
      expect(response_body['oecTaskStatus']['status']).to eq 'In progress'
    end

    context 'missing term name' do
      let(:term_name) { nil }
      it 'should return error before task is initialized' do
        make_request
        expect(Oec::ApiTaskWrapper).not_to receive(:new)
        expect(response.status).to eq 500
      end
    end

    context 'unknown task name' do
      let(:task_name) { 'SheepShearTask' }
      it 'should return error before task is initialized' do
        make_request
        expect(Oec::ApiTaskWrapper).not_to receive(:new)
        expect(response.status).to eq 500
      end
    end
  end

  describe '#task_status' do
    let(:make_request) { get :task_status, task_id: task_id }
    let(:task_id) { Oec::ApiTaskWrapper.generate_task_id }

    it_should_behave_like 'an api endpoint' do
      before { allow(Oec::Task).to receive(:fetch_from_cache).and_raise RuntimeError, 'Something went wrong' }
    end

    context 'task not found for id' do
      before { expect(Oec::Task).to receive(:fetch_from_cache).with(task_id).and_return nil }

      it 'should return bad request error' do
        make_request
        expect(response.status).to eq 400
      end
    end

    context 'task found for id' do
      before do
        allow(Oec::RemoteDrive).to receive(:new).and_return double
        Oec::TermSetupTask.new(term_code: '2013-C', api_task_id: task_id, log_to_cache: true)
      end

      it 'should return task status and log' do
        make_request
        expect(response.status).to eq 200
        response_body = JSON.parse response.body
        expect(response_body['oecTaskStatus']['status']).to eq 'In progress'
        expect(response_body['oecTaskStatus']['log']).to eq []
      end
    end
  end
end

