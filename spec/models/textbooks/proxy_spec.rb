require "spec_helper"

describe Textbooks::Proxy do

  # We do not use shared_examples so as to avoid hammering an external data source
  # with redundant requests.
  def it_is_a_normal_server_response
    expect(subject[:statusCode]).to be_blank
    expect(subject[:books][:items]).to be_an_instance_of Array
  end
  def it_has_at_least_one_title
    feed = subject[:books]
    expect(feed[:items]).to be_an_instance_of Array
    expect(feed[:items].length).to be > 1
    first_book = feed[:items][0]
    expect(first_book[:title]).to be_present
    expect(first_book[:author]).to be_present
  end

  describe '#get' do
    describe 'live testext tests enabled for order-independent expectations', testext: true do
      subject { Textbooks::Proxy.new({
        course_catalog: course_catalog,
        dept: dept,
        section_numbers: section_numbers,
        slug: slug
      }).get }

      context 'valid section numbers and term slug' do
        let(:course_catalog) { '130' }
        let(:dept) { 'COLWRIT' }
        let(:section_numbers) { ['001'] }
        let(:slug) { 'spring-2015' }
        it 'produces the expected textbook feed' do
          it_is_a_normal_server_response
          it_has_at_least_one_title
          book_list = subject[:books][:items]
          first_book = book_list[0]
          [:isbn, :image, :amazonLink, :cheggLink, :oskicatLink, :googlebookLink, :bookstoreInfo].each do |key|
            expect(first_book[key]).to be_present
          end
          expect(first_book[:image]).to_not match /http:/
        end
      end

      context 'an unknown section number' do
        let(:course_catalog) { '130A' }
        let(:dept) { 'MCELLBI' }
        let(:section_numbers) { ['101'] }
        let(:slug) { 'spring-2015' }
        it 'returns a helpful message' do
          it_is_a_normal_server_response
          feed = subject[:books]
          expect(feed[:bookUnavailableError]).to eq 'Currently, there is no textbook information for this course. Check again later for updates, or contact your instructor directly.'
        end
      end

      context 'multiple section numbers' do
        let(:course_catalog) { '130A' }
        let(:dept) { 'MCELLBI' }
        let(:section_numbers) { ['101', '001'] }
        let(:slug) { 'spring-2015' }
        it 'finds the one with books' do
          it_is_a_normal_server_response
          it_has_at_least_one_title
        end
      end
    end

    describe 'order-dependent tests work from recorded data' do
      subject { Textbooks::Proxy.new({
        course_catalog: course_catalog,
        dept: dept,
        section_numbers: section_numbers,
        slug: slug,
        fake: true
      }).get }

      context 'a correct author and title' do
        let(:course_catalog) { '109G' }
        let(:dept) { 'POL SCI' }
        let(:section_numbers) { ['001'] }
        let(:slug) { 'fall-2014' }
        it 'provides a bookstore link to get the non-ISBN text' do
          it_is_a_normal_server_response
          it_has_at_least_one_title
          items = subject[:books][:items]
          expect(items[1][:author]).to eq 'SIDES'
          expect(items[1][:title]).to eq 'CAMPAIGNS+ELECTIONS 2012 ELECTION UPD. (Required)'
        end
      end

    end

  end

  describe '#get_as_json' do
    include_context 'it writes to the cache'
    it 'returns proper JSON' do
      json = Textbooks::Proxy.new({
        course_catalog: '109G',
        dept: 'POL SCI',
        section_numbers: ['001'],
        slug: 'fall-2014'
      }).get_as_json
      expect(json).to be_present
      parsed = JSON.parse(json)
      expect(parsed).to be
      unless parsed['statusCode'] && parsed['statusCode'] >= 400
        expect(parsed['books']).to be
      end
    end
    context 'when the bookstore server has problems' do
      before do
        stub_request(:any, /#{Regexp.quote(Settings.textbooks_proxy.base_url)}.*/).to_raise(Errno::EHOSTUNREACH)
      end
      it 'returns a error status code and message' do
        json = Textbooks::Proxy.new({
          course_catalog: '109G',
          dept: 'POL SCI',
          section_numbers: ['001'],
          slug: 'fall-2014',
          fake: false
        }).get_as_json
        parsed = JSON.parse(json)
        expect(parsed['statusCode']).to be >= 400
        expect(parsed['body']).to be_present
      end
    end
  end

end
