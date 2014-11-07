require 'spec_helper'

describe 'Batch CRUD of Google events' do
  let(:user_id) { rand(999999).to_s }
  let!(:valid_payload) do
    {
      'calendarId' => 'primary',
      'summary' => 'Fancy event',
      'start' => {
        'dateTime' => '2013-09-24T02:06:00.000-07:00'
      },
      'end' => {
        'dateTime' => '2013-09-24T03:06:00.000-07:00'
      }
    }
  end
  let!(:another_valid_payload) do
    {
      'calendarId' => 'primary',
      'summary' => 'Plain event',
      'start' => {
        'dateTime' => '2013-09-24T04:06:00.000-07:00'
      },
      'end' => {
        'dateTime' => '2013-09-24T04:06:00.000-07:00'
      }
    }
  end
  let(:invalid_payload) do
    {
      'calendarId' => 'primary',
      'summary' => 'Fancy event',
      'start' => {
        'dateTime' => '2013-09-24T02:06:00.000-07:00'
      },
      'end' => {
        'dateTime' => '2013-09-24T03:06:00.000-07:0'
      }
    }
  end
  let(:token_info) {
    {
      access_token: Settings.google_proxy.test_user_access_token,
      refresh_token: Settings.google_proxy.test_user_refresh_token,
      expiration_time: 0
    }
  }
  let(:real_insert_proxy) { GoogleApps::EventsBatchInsert.new(token_info) }
  let(:real_delete_proxy) { GoogleApps::EventsBatchDelete.new(token_info) }
  let(:real_get_proxy) { GoogleApps::EventsBatchGet.new(token_info) }
  let(:real_update_proxy) { GoogleApps::EventsBatchUpdate.new(token_info) }

  context 'real insert event test', testext: true do

    context 'invalid payload' do
      subject { real_insert_proxy.insert_event(invalid_payload, nil) }
      it 'should not allow creation of the event' do
        expect(subject.status).to eq 400
        expect(subject.data).to be
        expect(subject.data.error).to be
      end
    end

    context 'valid payload' do
      it 'should create, then update, then retrieve, then delete a pair of events' do

        event_ids = []

        delete_proc = Proc.new { |result|
          insert_id = result.data['id']
          real_delete_proxy.queue_event(insert_id)
        }

        get_proc = Proc.new { |result|
          event_id = result.data['id']
          event_ids << event_id
          real_get_proxy.queue_event(event_id, delete_proc)
        }

        update_proc = Proc.new { |result|
          event_id = result.data['id']
          body = valid_payload
          body['summary'] = result.data['summary'] + ' updated'
          real_update_proxy.queue_event(event_id, body, get_proc)
        }

        real_insert_proxy.queue_event(valid_payload, update_proc)
        real_insert_proxy.queue_event(another_valid_payload, update_proc)

        # insert 2 events
        insert_response = real_insert_proxy.run_batch

        expect(insert_response.length).to eq 2
        expect(insert_response[0].status).to eq 200
        expect(insert_response[0].data['summary']).to eq('Fancy event')
        expect(insert_response[0].data['status']).to eq('confirmed')
        expect(insert_response[1].data['summary']).to eq('Plain event')
        expect(insert_response[1].data['status']).to eq('confirmed')

        # now update them
        update_response = real_update_proxy.run_batch
        expect(update_response.length).to eq 2
        puts "update response 0 = #{update_response[0].inspect}"
        puts "update response 1 = #{update_response[1].inspect}"
        expect(update_response[0].status).to eq 200

        # now get the 2 events
        get_response = real_get_proxy.run_batch
        expect(get_response.length).to eq 2
        expect(get_response[0].status).to eq 200
        expect(get_response[0].data['summary']).to eq('Fancy event updated')
        expect(get_response[1].data['summary']).to eq('Plain event updated')

        # now delete the events we created
        delete_response = real_delete_proxy.run_batch
        expect(delete_response.length).to eq 2
        expect(delete_response[0].status).to eq 204
        expect(delete_response[1].status).to eq 204

        # now try to get the events again, they should be cancelled now
        event_ids.each do |id|
          real_get_proxy.queue_event id
        end
        get_response = real_get_proxy.run_batch
        expect(get_response.length).to eq 2
        get_response.each do |response|
          expect(response.status).to eq 200
          expect(response.data['status']).to eq('cancelled')
        end
      end
    end

  end
end
