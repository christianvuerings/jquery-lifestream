require 'spec_helper'

describe Calendar::LoggedEntry do
  describe '#lookup' do
    before do
      Calendar::LoggedEntry.create(
        {
          year: 2014,
          term_cd: 'B',
          ccn: 1234,
          multi_entry_cd: 'A',
          job_id: 1,
          event_id: 'foo'})
      Calendar::LoggedEntry.create(
        {
          year: 2014,
          term_cd: 'B',
          ccn: 1234,
          multi_entry_cd: 'A',
          job_id: 2,
          event_id: 'abcdef'})
    end

    it 'should return the second logged entry' do
      queued = Calendar::QueuedEntry.create(
        {
          year: 2014,
          term_cd: 'B',
          ccn: 1234,
          multi_entry_cd: 'A'})

      found = Calendar::LoggedEntry.lookup queued
      expect(found).to be
      expect(found.job_id).to eq 2
      expect(found.event_id).to eq 'abcdef'
    end

    it 'should return nothing when logged entry is not found' do
      queued = Calendar::QueuedEntry.create(
        {
          year: 2013,
          term_cd: 'A',
          ccn: 1234,
          multi_entry_cd: 'A'})

      found = Calendar::LoggedEntry.lookup queued
      expect(found).to be_nil
    end
  end
end
