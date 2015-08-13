module CampusSolutionsHelperModule

  shared_examples 'a simple proxy that returns errors' do
    before {
      proxy.set_response(status: 506, body: '')
    }
    it 'returns errors properly' do
      expect(subject[:errored]).to eq true
    end
  end
end
