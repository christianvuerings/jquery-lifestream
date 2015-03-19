class MyEventsController < ApplicationController
  include ClassLogger
  before_filter :authenticate, :check_google_access
  respond_to :json

  def create
    input = sanitize_input!(params)
    if input.present?
      logger.info "Creating event for user #{session['user_id']}: #{input}"
      response = GoogleApps::EventsInsert.new(user_id: session['user_id']).insert_event(input.stringify_keys)

      result = response.data || {}
      if result.blank?
        logger.warn "GoogleApps::EventsInsert.insert_event response for user #{session['user_id']} should not be blank.
          Payload: #{input.inspect}"
      end
      result = result.to_hash.merge({ status:true }) unless result.blank?
      return respond_with(result) do |format|
        format.json { render json: result.to_json, status: response.status}
      end
    end

    error_response
  end

  private
  def check_google_access
    return error_response unless current_user.policy.access_google?
    return error_response unless GoogleApps::Proxy.access_granted?(session['user_id'])
  end

  def error_response
    result = { status: false }
    respond_with(result) do |format|
      format.json { render json: result.to_json, status: :bad_request }
    end
  end

  def sanitize_input!(params)
    result = {}
    result[:summary] = params['summary'] if params['summary'].present?
    %w(start end).each do |key|
      if params[key] && params[key][:epoch]
        date_time = DateTime.strptime(params[key][:epoch].to_s, '%s') rescue ''
        result[key.to_sym] = { dateTime: date_time.new_offset('-7:00').rfc3339(3) } if date_time.present?
      end
    end

    valid = %w(summary start end).all? { |key| result[key.to_sym].present? }
    return {} unless valid

    {calendarId: "primary"}.merge(result)
  end

end
