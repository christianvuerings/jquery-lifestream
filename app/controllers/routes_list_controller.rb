class RoutesListController < ApplicationController
  extend Calcentral::Cacheable

  respond_to :json

  def smoke_test_routes
    return respond_with({}) unless session[:user_id] and UserAuth.is_superuser?(session[:user_id])
    test_routes = self.class.fetch_from_cache do
      get_smoke_test_routes
    end
    respond_with({routes: test_routes})
  end

  private

  def get_smoke_test_routes
    # This gets all the GET routes matching /api/...
    test_routes = Rails.application.routes.routes.map do |r|
      if (r.constraints.present? && !(r.constraints[:request_method] =~ 'POST').nil?)
        ''
      elsif r.path.spec.to_s.starts_with?('/api/')
        r.path.spec.to_s.chomp('(.:format)')
      else
        ''
      end
    end
    blacklist = %w(
        /api/my/campuslinks/expire
        /api/clear_cache
        /api/canvas/request_authorization
        /api/google/request_authorization
        /api/google/handle_callback
      )
    test_routes.reject {|x| x.empty? || blacklist.include?(x)}
  end
end