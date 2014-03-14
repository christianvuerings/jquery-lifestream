# Intended for use with Rails Controllers related to Canvas external applications
#
# Usage:
#
#   class MyCanvasCourseToolController < ApplicationController
#     include Canvas::AuthorizationHelpers
#     before_filter :authenticate_cas_user!
#     before_filter :authenticate_canvas_user!
#     before_filter :authenticate_canvas_course_user!
#     before_filter :authorize_canvas_course_admin!
#     rescue_from Errors::ClientError, with: :handle_client_error
#   end
#
# The before_filter callbacks need to be defined in the correct order, so that they are added to the filter chain in the right order.
# Filter methods such as #authenticate_canvas_course_user! set the @canvas_course_user variable in the controller with details provided by Canvas::CourseUser,
# which are used by #authorize_canvas_course_admin! to verify the admin status of the user within the Canvas course site.
#
# The filter methods provided raise subclasses of Errors::ClientError, such as when authentication or authorization fails. These are meant to be
# caught and used by #handle_client_error to respond in the manner intended.
#
module Canvas
  module AuthorizationHelpers

    def authenticate_cas_user!
      if session[:user_id].blank?
        raise Errors::UnauthorizedError, "No session user"
      end
    end

    def authenticate_canvas_user!
      if session[:canvas_user_id].blank?
        ldap_user_id = session[:user_id]
        canvas_user_profile_response = Canvas::UserProfile.new(user_id: ldap_user_id).user_profile
        if canvas_user_profile_response.status == 200
          canvas_user_profile = JSON.parse(canvas_user_profile_response.body)
          session[:canvas_user_id] = canvas_user_profile['id'].to_s
        else
          raise Errors::UnauthorizedError, "Unable to identify Canvas User ID for UID: #{ldap_user_id}."
        end
      end
    end

    def authenticate_canvas_course_user!
      session[:canvas_course_id] = params[:canvas_course_id] unless params[:canvas_course_id].blank?
      raise Errors::UnauthorizedError, "No canvas course id" if session[:canvas_course_id].blank?
      @canvas_user_id = Integer(session[:canvas_user_id], 10)
      @canvas_course_id = Integer(session[:canvas_course_id], 10)
      canvas_course_user_proxy = Canvas::CourseUser.new(:user_id => @canvas_user_id, :course_id => @canvas_course_id)
      unless @canvas_course_user = canvas_course_user_proxy.course_user
        raise Errors::ForbiddenError, "Canvas user #{@canvas_user_id} is not a member of Course ID #{@canvas_course_id}"
      end
    end

    def authorize_canvas_course_admin!
      raise Errors::ForbiddenError, "User is not a canvas course admin" unless Canvas::CourseUser.is_course_admin?(@canvas_course_user)
    end

    def handle_client_error(error)
      case error.class.to_s
        when 'Errors::UnauthorizedError'
          logger.warn "Request made to #{controller_name}\##{action_name} unauthorized: #{error.message}"
          render nothing: true, status: 401 and return
        when 'Errors::ForbiddenError'
          logger.warn "Request made to #{controller_name}\##{action_name} forbidden: #{error.message}"
          render nothing: true, status: 403 and return
        else
          logger.error "Exception occured with #{controller_name}\##{action_name}: #{error.class} - #{error.message}"
          render json: {:error => error.message}.to_json, status: 500 and return
      end
    end

    def handle_api_exception(error)
      logger.error "#{error.class} raised under #{controller_name}\##{action_name}: #{error.message}"
      render json: {:error => error.message}.to_json, status: 500
    end

  end
end
