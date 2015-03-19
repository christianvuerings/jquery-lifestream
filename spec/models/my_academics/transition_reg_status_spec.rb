require 'spec_helper'

describe MyAcademics::TransitionRegStatus do
  let(:oski_uid) { '61889' }
  let(:feed) { {collegeAndLevel: college_and_level_data} }
  let(:merged_feed) { MyAcademics::TransitionRegStatus.new(oski_uid).merge(feed); feed }

  shared_examples 'should not merge' do
    it { expect(merged_feed.has_key? :transitionRegStatus).to eq false }
  end

  shared_examples 'should return nil status' do
    it { expect(merged_feed[:transitionRegStatus]).to be_nil }
  end

  context 'when collegeAndLevel is missing' do
    let(:feed) { {} }
    include_examples 'should not merge'
  end

  context 'when collegeAndLevel is empty' do
    let(:college_and_level_data) { {empty: true} }
    include_examples 'should not merge'
  end

  context 'when collegeAndLevel reports no student ID' do
    let(:college_and_level_data) { {noStudentId: true} }
    include_examples 'should not merge'
  end

  context 'when collegeAndLevel contains profile information for the term' do
    let(:fake) { true }
    let(:regstatus_proxy) { Regstatus::Proxy.new(user_id: oski_uid, fake: fake) }
    let(:profile_proxy) { profile_proxy = Bearfacts::Profile.new(user_id: oski_uid, fake: fake) }

    before do
      allow(Regstatus::Proxy).to receive(:new).and_return(regstatus_proxy)
      allow(Bearfacts::Profile).to receive(:new).and_return(profile_proxy)
    end

    let(:college_and_level_data) do
      data = {}
      MyAcademics::CollegeAndLevel.new(oski_uid).merge(data)
      data[:collegeAndLevel].merge(termName: term_name)
    end

    context 'when collegeAndLevel term is the CalCentral current term' do
      let(:term_name) { Berkeley::Terms.fetch.current.to_english }
      include_examples 'should return nil status'
    end

    context 'when collegeAndLevel term is not the CalCentral current term' do
      let(:term_name) { Berkeley::Terms.fetch.next.to_english }
      it 'returns transition status for the CalCentral current term' do
        expect(merged_feed[:transitionRegStatus][:termName]).to eq Berkeley::Terms.fetch.current.to_english
      end

      context 'when student is registered' do
        before do
          regstatus_proxy.override_json { |json| json['regStatus']['isRegistered'] = true }
        end
        it 'should return true registration' do
          expect(merged_feed[:transitionRegStatus][:registered]).to eq true
        end
      end

      context 'when student is not registered' do
        before do
          regstatus_proxy.override_json { |json| json['regStatus']['isRegistered'] = false }
        end
        it 'should return false registration' do
          expect(merged_feed[:transitionRegStatus][:registered]).to eq false
        end
      end

      context 'when proxy returns an error' do
        before { allow_any_instance_of(Regstatus::Proxy).to receive(:get).and_return({errored: true}) }
        include_examples 'should return nil status'
      end
    end

  end
end
