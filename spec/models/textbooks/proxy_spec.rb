require "spec_helper"

describe Textbooks::Proxy do

  # We do not use shared_examples so as to avoid hammering an external data source
  # with redundant requests.
  def it_is_a_normal_server_response
    expect(subject[:statusCode]).to be_blank
    expect(subject[:books]).to be_present
  end
  def it_has_at_least_one_title
    feed = subject[:books]
    expect(feed[:hasBooks]).to be_true
    expect(feed[:bookDetails][0][:hasChoices]).to be_false
    first_book = feed[:bookDetails][0][:books][0]
    expect(first_book[:title]).to be_present
    expect(first_book[:author]).to be_present
  end

  describe '#get' do
    subject { Textbooks::Proxy.new({ccns: ccns, slug: slug}).get }

    context 'valid CCN and term slug' do
      let(:ccns) { ['26262'] }
      let(:slug) {'fall-2014'}
      it 'produces the expected textbook feed' do
        it_is_a_normal_server_response
        it_has_at_least_one_title
        book_list = subject[:books][:bookDetails][0]
        expect(book_list[:type]).to eq 'Required'
        first_book = book_list[:books][0]
        [:isbn, :image, :edition, :publisher, :amazonLink, :cheggLink, :oskicatLink, :googlebookLink].each do |key|
          expect(first_book[key]).to be_present
        end
        expect(first_book[:image]).to_not match /http:/
      end
    end

    context 'multiple CCNs, only one of which has books' do
      let(:ccns) { ['09259', '26262'] }
      let(:slug) {'fall-2014'}
      it 'finds the one with books' do
        it_is_a_normal_server_response
        it_has_at_least_one_title
      end
    end

    context 'an unknown CCN' do
      let(:ccns) { ['09259'] }
      let(:slug) {'fall-2014'}
      it 'returns a helpful message' do
        it_is_a_normal_server_response
        feed = subject[:books]
        expect(feed[:hasBooks]).to be_false
        expect(feed[:bookUnavailableError]).to eq 'Textbook information for this course could not be found.'
      end
    end

    context 'an unknown term code' do
      let(:ccns) { ['26262'] }
      let(:slug) {'fall-2074'}
      it 'returns a helpful message' do
        it_is_a_normal_server_response
        feed = subject[:books]
        expect(feed[:hasBooks]).to be_false
        expect(feed[:bookUnavailableError]).to eq 'Textbook information for this term could not be found.'
      end
    end

    # TODO We no longer have an example of a bookstore page with choices. When we find one, redo this test!
    # it "should return true for hasChoices when there are choices for a book"

    context 'when the bookstore server has problems' do

    end
  end

  describe '#get_as_json' do
    include_context 'it writes to the cache'
    subject { Textbooks::Proxy.new({ccns: ['26262'], slug: 'fall-2014'}).get_as_json }
    it 'returns proper JSON' do
      expect(subject).to be_present
      parsed_response = JSON.parse(subject)
      expect(parsed_response).to be
      unless parsed_response['statusCode'] && parsed_response['statusCode'] >= 400
        expect(parsed_response['books']).to be
      end
    end
  end

end
