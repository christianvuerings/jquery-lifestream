require 'spec_helper'

describe Calmail::CheckNamespace do
  let(:list_name) { "site-#{random_id}" }

  describe '#name_available?' do
    subject { described_class.new(fake: true) }
    before do
      subject.set_response(mock_response)
    end
    let(:result) { subject.name_available?(list_name)[:response] }
    context 'mailing list already exists' do
      let(:mock_response) { subject.mock_response_list_name_exists }
      it 'finds it' do
        expect(result).to be false
      end
    end
    context 'mailing list does not exist' do
      let(:mock_response) { subject.mock_response }
      it 'finds nothing' do
        expect(result).to be true
      end
    end
    context 'some other error' do
      let(:mock_response) do
        subject.mock_response.merge(
          status: 500,
          body: '{"tg_flash": null, "message": "Invalid: Value must be from 2 to 50 characters in length"}'
        )
      end
      it 'reports failure' do
        expect(result[:statusCode]).to eq 503
      end
    end
  end

  describe '#check_namespace' do
    context 'using real data feed', testext: true do
      let(:response) { subject.check_namespace(list_name) }
      context 'known mailing list' do
        let(:list_name) {'raytest'}
        it 'freaks out' do
          expect(response.code).to eq 500
          expect(response.parsed_response).to eq({
                'tg_flash' => nil,
                'message' => Calmail::CheckNamespace::MAILING_LIST_EXISTS
              })
        end
      end
      context 'unknown mailing list' do
        let(:list_name) {'pleasedonotcreateamailinglistcalledthis'}
        it 'affirms absence' do
          expect(response.code).to eq 200
          expect(response.parsed_response).to eq({
                'tg_flash' => nil,
                'available' => true
              })
        end
      end
    end
  end

end
