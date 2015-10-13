module CampusSolutions
  class CampusSolutionsController < ApplicationController

    include ClassLogger

    before_filter :api_authenticate_401

    def json_passthrough(classname, params={})
      render json: classname.new(params).get
    end

    def post_passthrough(classname)
      model = classname.from_session session
      render json: model.update(request.request_parameters)
    end

    def delete_passthrough(classname)
      model = classname.from_session session
      render json: model.delete(params)
    end

    def exclude_acting_as_users
      unless current_user.directly_authenticated?
        logger.warn "ACT-AS: User #{current_user.original_user_id} attempted access to an endpoint which is forbidden while acting-as user #{current_user.user_id}"
        render :nothing => true, :status => 403
      end
    end

  end
end
