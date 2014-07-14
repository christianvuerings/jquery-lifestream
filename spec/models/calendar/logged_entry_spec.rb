require 'spec_helper'

describe Calendar::LoggedEntry do
  describe '#lookup' do
    before do
      first = Calendar::LoggedEntry.new
      first.year = 2014
      first.term_cd = 'B'
      first.ccn = 1234
      first.multi_entry_cd = 'A'
      first.job_id = 1
      first.event_id = 'foo'
      first.save
      second = Calendar::LoggedEntry.new
      second.year = 2014
      second.term_cd = 'B'
      second.ccn = 1234
      second.multi_entry_cd = 'A'
      second.job_id = 2
      second.event_id = 'abcdef'
      second.save
    end

    it 'should return the second logged entry' do
      queued = Calendar::QueuedEntry.new
      queued.year = 2014
      queued.term_cd = 'B'
      queued.ccn = 1234
      queued.multi_entry_cd = 'A'

      found = Calendar::LoggedEntry.lookup queued
      expect(found).to be
      expect(found.job_id).to eq 2
      expect(found.event_id).to eq 'abcdef'
    end

    it 'should return nothing when logged entry is not found' do
      queued = Calendar::QueuedEntry.new
      queued.year = 2013
      queued.term_cd = 'A'
      queued.ccn = 1234
      queued.multi_entry_cd = 'A'

      found = Calendar::LoggedEntry.lookup queued
      expect(found).to be_nil
    end
  end
end
