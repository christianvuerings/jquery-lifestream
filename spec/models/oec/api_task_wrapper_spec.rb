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

  context 'validate without export' do
    let(:task_class) { Oec::ExportTask }
    let(:params) { {'term' => 'Summer 2014', 'departmentCode' => 'SYPSY'} }
    it 'should implicitly add :validate_without_export' do
      expect(translated_params[:validate_without_export]).to be true
    end
  end

end
