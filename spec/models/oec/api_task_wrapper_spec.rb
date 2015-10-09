describe Oec::ApiTaskWrapper do

  let(:wrapper) { Oec::ApiTaskWrapper.new(task_class, params)  }
  let(:translated_params) { wrapper.instance_variable_get :@params }

  context 'params without department code' do
    let(:task_class) { Oec::TermSetupTask }
    let(:params) { {'term' => 'Summer 2014'} }
    it 'should translate term to code' do
      expect(translated_params[:term_code]).to eq '2014-C'
    end
    it 'should not populate department options' do
      expect(translated_params[:dept_codes]).to be_nil
      expect(translated_params[:import_all]).to be_nil
    end
  end

  context 'params with department code' do
    let(:task_class) { Oec::SisImportTask }
    let(:params) { {'term' => 'Summer 2014', 'departmentCode' => 'SYPSY'} }
    it 'should translate params to task options' do
      expect(translated_params[:dept_codes]).to eq 'SYPSY'
      expect(translated_params[:import_all]).to eq true
      expect(translated_params[:validate_without_export]).to be_nil
    end
  end

  context 'starting background tasks' do
    let(:wrapper) { Oec::ApiTaskWrapper.new(Oec::TermSetupTask, {'term' => 'Summer 2014'}) }

    before do
      allow(Oec::RemoteDrive).to receive(:new).and_return double
      allow(wrapper).to receive(:background).and_return wrapper
      allow_any_instance_of(Oec::TermSetupTask).to receive(:run)
    end

    it 'launches tasks with a retrievable id' do
      task_status = wrapper.start_in_background
      expect(task_status[:status]).to eq 'In progress'
      expect(Oec::Task.fetch_from_cache task_status[:id]).to be_present
    end
  end

end
