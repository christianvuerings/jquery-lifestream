require "spec_helper"

describe Canvas::Terms do
  before {@terms = Canvas::Terms.fetch}

  it 'should return an array of terms from Canvas' do
    expect(@terms).to be_a Array
    expect(@terms).to_not be_empty
  end

  it 'should return terms as hashes with id, name, and (unless default term) SIS ID' do
    @terms.each do |term|
      expect(term).to be_a Hash
      expect(term['id']).to be_a Integer
      expect(term['name']).to be_a String
      unless term['name'] == 'Default Term'
        expect(term['sis_term_id']).to be_a String
        expect(term['sis_term_id']).to match(/\A(TERM:)?\d{4}\-[A-Z]+\Z/)
      end
    end
  end
end
