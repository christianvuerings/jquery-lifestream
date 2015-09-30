class OecTasksController < ApplicationController
  include ClassLogger

  before_action :api_authenticate
  before_action :authorize_oec_administration

  rescue_from StandardError, with: :handle_api_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_oec_administration
    authorize current_user, :can_administer_oec?
  end

  # GET /api/oec_tasks

  def index
    departments = Berkeley::Departments.department_map.map { |k,v| {code: k, name: Berkeley::Departments.shortened(v)} }
    render json: {
      oecDepartments: departments.sort_by { |dept| dept[:name] },
      oecTasks: Oec::Task.subclasses.map { |klass| klass.to_s.demodulize },
      oecTerms: Berkeley::Terms.fetch.campus.values.map { |term| term.to_english }
    }
  end

  # POST /api/oec_tasks/:task_name

  def run
    task_class = "Oec::#{params['task_name']}".constantize
    params.require('term')
    task_opts = params.slice('term', 'departmentCode')
    Oec::ApiTaskWrapper.new(task_class, task_opts).start_in_background
    render json: {success: true, oecDriveUrl: Oec::RemoteDrive::HUMAN_URL}
  end

end
