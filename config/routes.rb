
Calcentral::Application.routes.draw do

  mount RailsAdmin::Engine => '/ccadmin', :as => 'rails_admin'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  root :to => 'bootstrap#index'

  # User management/status endpoints.
  get '/api/my/am_i_logged_in' => 'user_api#am_i_logged_in', :as => :am_i_logged_in, :defaults => { :format => 'json' }
  get '/api/my/status' => 'user_api#mystatus', :as => :mystatus, :defaults => { :format => 'json' }
  post '/api/my/record_first_login' => 'user_api#record_first_login', :as => :record_first_login, :defaults => { :format => 'json' }, :via => :post
  post '/api/my/opt_out'=> 'user_api#delete', :via => :post
  post '/api/my/calendar/opt_in' => 'user_api#calendar_opt_in', :via => :post
  post '/api/my/calendar/opt_out' => 'user_api#calendar_opt_out', :via => :post

  # Feeds of read-only content
  get '/api/my/classes' => 'my_classes#get_feed', :as => :my_classes, :defaults => { :format => 'json' }
  get '/api/my/photo' => 'photo#my_photo', :as => :my_photo, :defaults => {:format => 'jpeg' }
  get '/api/my/textbooks_details' => 'my_textbooks#get_feed', :as => :my_textbooks, :defaults => { :format => 'json' }
  get '/api/my/up_next' => 'my_up_next#get_feed', :as => :my_up_next, :defaults => { :format => 'json' }
  get '/api/my/tasks' => 'my_tasks#get_feed', :via => :get, :as => :my_tasks, :defaults => { :format => 'json' }
  get '/api/my/groups' => 'my_groups#get_feed', :as => :my_groups, :defaults => { :format => 'json' }
  get '/api/my/activities' => 'my_activities#get_feed', :as => :my_activities, :defaults => { :format => 'json' }
  get '/api/my/badges' => 'my_badges#get_feed', :as => :my_badges, :defaults => { :format => 'json' }
  get '/api/my/academics' => 'my_academics#get_feed', :as => :my_academics, :defaults => { :format => 'json' }
  get '/api/my/financials' => 'my_financials#get_feed', :as => :my_financials, :defaults => {:format => 'json'}
  get '/api/my/finaid' => 'my_finaid#get_feed', :as => :my_finaid, :defaults => {:format => 'json'}
  get '/api/my/cal1card' => 'my_cal1card#get_feed', :as => :my_cal1card, :defaults => {:format => 'json'}
  get '/api/my/advising' => 'my_advising#get_feed', :as => :my_advising, :defaults => {:format => 'json'}
  get '/api/my/campuslinks' => 'my_campus_links#get_feed', :as => :my_campus_links, :defaults => { :format => 'json' }
  get '/api/my/campuslinks/expire' => 'my_campus_links#expire'
  get '/api/my/updated_feeds' => 'is_updated#list', :defaults => {:format => 'json'}
  get '/api/blog' => 'blog_feed#get_blog_info', :as => :blog_info, :defaults => { :format => 'json' }
  get '/api/search_users/:id' => 'search_users#search_users', :via => :get, :defaults => { :format => 'json' }
  get '/api/search_users/uid/:id' => 'search_users#search_users_by_uid', :via => :get, :defaults => { :format => 'json' }
  get '/api/media/:year/:term_code/:dept/:catalog_id' => 'mediacasts#get_media', :defaults => { :format => 'json' }

  # Google API writing endpoints
  post '/api/my/event' => 'my_events#create', via: :post, defaults: { format: 'json' }
  post '/api/my/tasks' => 'my_tasks#update_task', :via => :post, :as => :update_task, :defaults => { :format => 'json' }
  post '/api/my/tasks/create' => 'my_tasks#insert_task', :via => :post, :as => :insert_task, :defaults => { :format => 'json' }
  post '/api/my/tasks/clear_completed' => 'my_tasks#clear_completed_tasks', :via => :post, :as => :clear_completed_tasks, :defaults => { :format => 'json' }
  post '/api/my/tasks/delete/:task_id' => 'my_tasks#delete_task', :via => :post, :as => :delete_task, :defaults => { :format => 'json' }

  # Canvas embedded application support.
  post '/canvas/embedded/*url' => 'canvas_lti#embedded', :defaults => { :format => 'html' }
  get '/canvas/lti_roster_photos' => 'canvas_lti#lti_roster_photos', :defaults => { :format => 'xml' }
  get '/canvas/lti_site_creation' => 'canvas_lti#lti_site_creation', :defaults => { :format => 'xml' }
  get '/canvas/lti_user_provision' => 'canvas_lti#lti_user_provision', :defaults => { :format => 'xml' }
  get '/canvas/lti_course_add_user' => 'canvas_lti#lti_course_add_user', :defaults => { :format => 'xml' }
  get '/canvas/lti_course_mediacasts' => 'canvas_lti#lti_course_mediacasts', :defaults => { :format => 'xml' }
  get '/canvas/lti_course_grade_export' => 'canvas_lti#lti_course_grade_export', :defaults => { :format => 'xml' }
  get '/canvas/lti_course_manage_official_sections' => 'canvas_lti#lti_course_manage_official_sections', :defaults => { :format => 'xml' }
  # A Canvas course ID of "embedded" means to retrieve from session properties.
  get '/api/academics/canvas/course_user_roles/:canvas_course_id' => 'canvas_course_add_user#course_user_roles', :defaults => { :format => 'json' }
  get '/api/academics/canvas/external_tools' => 'canvas#external_tools', :defaults => { :format => 'json' }
  get '/api/academics/canvas/user_can_create_site' => 'canvas#user_can_create_site', :defaults => { :format => 'json' }
  get '/api/academics/canvas/egrade_export/download/:canvas_course_id' => 'canvas_course_grade_export#download_egrades_csv', :defaults => { :format => 'csv' }
  get '/api/academics/canvas/egrade_export/options/:canvas_course_id' => 'canvas_course_grade_export#export_options', :defaults => { :format => 'json' }
  get '/api/academics/canvas/egrade_export/is_official_course' => 'canvas_course_grade_export#is_official_course', :defaults => { :format => 'json' }
  get '/api/academics/canvas/egrade_export/status/:canvas_course_id' => 'canvas_course_grade_export#job_status', :defaults => { :format => 'json' }
  post '/api/academics/canvas/egrade_export/prepare/:canvas_course_id' => 'canvas_course_grade_export#prepare_grades_cache', :defaults => { :format => 'json' }
  get '/api/academics/rosters/canvas/:canvas_course_id' => 'canvas_rosters#get_feed', :as => :canvas_roster, :defaults => { :format => 'json' }
  get '/api/academics/rosters/campus/:campus_course_id' => 'campus_rosters#get_feed', :as => :campus_roster, :defaults => { :format => 'json' }
  get '/api/academics/rosters/canvas/csv/:canvas_course_id' => 'canvas_rosters#get_csv', :as => :canvas_roster_csv, :defaults => { :format => 'csv' }
  get '/api/academics/rosters/campus/csv/:campus_course_id' => 'campus_rosters#get_csv', :as => :campus_roster_csv, :defaults => { :format => 'csv' }
  get '/canvas/:canvas_course_id/photo/:person_id' => 'canvas_rosters#photo', :defaults => { :format => 'jpeg' }, :action => 'show'
  get '/canvas/:canvas_course_id/profile/:person_id' => 'canvas_rosters#profile'
  get '/campus/:campus_course_id/photo/:person_id' => 'campus_rosters#photo', :defaults => { :format => 'jpeg' }, :action => 'show'
  get '/api/academics/canvas/course_provision' => 'canvas_course_provision#get_feed', :as => :canvas_course_provision, :defaults => { :format => 'json' }
  get '/api/academics/canvas/course_provision_as/:admin_acting_as' => 'canvas_course_provision#get_feed', :as => :canvas_course_provision_as, :defaults => { :format => 'json' }
  post '/api/academics/canvas/course_provision/create' => 'canvas_course_provision#create_course_site', :via => :post, :as => :canvas_course_create, :defaults => { :format => 'json' }
  get '/api/academics/canvas/course_provision/sections_feed/:canvas_course_id' => 'canvas_course_provision#get_sections_feed', :as => :canvas_course_sections_feed, :defaults => { :format => 'json' }
  post '/api/academics/canvas/course_provision/edit_sections/:canvas_course_id' => 'canvas_course_provision#edit_sections', :via => :post, :as => :canvas_course_edit_sections, :defaults => { :format => 'json' }
  get '/api/academics/canvas/course_provision/status' => 'canvas_course_provision#job_status', :via => :get, :as => :canvas_course_job_status, :defaults => { :format => 'json' }
  post '/api/academics/canvas/project_provision/create' => 'canvas_project_provision#create_project_site', :via => :post, :as => :canvas_project_create, :defaults => { :format => 'json' }
  post '/api/academics/canvas/user_provision/user_import' => 'canvas_user_provision#user_import', :as => :canvas_user_provision_import, :defaults => { :format => 'json' }
  get '/api/academics/canvas/site_creation/authorizations' => 'canvas_site_creation#authorizations', :as => :canvas_site_creation_authorizations, :defaults => { :format => 'json' }
  get '/api/academics/canvas/course_add_user/:canvas_course_id/search_users' => 'canvas_course_add_user#search_users', :via => :get, :as => :canvas_course_add_user_search_users, :defaults => { :format => 'json' }
  get '/api/academics/canvas/course_add_user/:canvas_course_id/course_sections' => 'canvas_course_add_user#course_sections', :via => :get, :as => :canvas_course_add_user_course_sections, :defaults => { :format => 'json' }
  post '/api/academics/canvas/course_add_user/:canvas_course_id/add_user' => 'canvas_course_add_user#add_user', :via => :post, :as => :canvas_course_add_user_add_user, :defaults => { :format => 'json' }
  get '/api/canvas/media/:canvas_course_id' => 'canvas_mediacasts#get_media', :defaults => { :format => 'json' }

  # System utility endpoints
  get '/api/cache/clear' => 'cache#clear', :defaults => { :format => 'json' }
  get '/api/cache/delete' => 'cache#delete', :defaults => { :format => 'json' }
  get '/api/cache/delete/:key' => 'cache#delete', :defaults => { :format => 'json' }
  get '/api/cache/warm/:uid' => 'cache#warm', :defaults => { :format => 'json' }
  get '/api/config' => 'config#get', :via => :get, :defaults => { :format => 'json' }
  get '/api/ping' => 'ping#do', :defaults => {:format => 'json'}
  get '/api/refresh_logging' => 'refresh_logging#refresh_logging', :defaults => { :format => 'json' }
  get '/api/tools/styles' => 'tools#get_styles', :via => :get
  get '/api/server_info' => 'server_runtime#get_info', :via => :get
  get '/api/stats' => 'stats#get_stats', :via => :get, :defaults => { :format => 'json' }
  get '/api/smoke_test_routes' => 'routes_list#smoke_test_routes', :as => :all_routes, :defaults => { :format => 'json' }

  # Oauth endpoints: Google
  get '/api/google/request_authorization'=> 'google_auth#request_authorization'
  get '/api/google/handle_callback' => 'google_auth#handle_callback'
  post '/api/google/remove_authorization' => 'google_auth#remove_authorization', :via => :post
  post '/api/google/dismiss_reminder' => 'google_auth#dismiss_reminder', :defaults => { :format => 'json'}, :via => :post

  # Authentication endpoints
  get '/auth/cas/callback' => 'sessions#lookup'
  get '/auth/failure' => 'sessions#failure'
  get '/reauth/admin' => 'sessions#reauth_admin', :as => :reauth_admin
  if Settings.developer_auth.enabled
    # the backdoor for http basic auth (bypasses CAS) only on development environments.
    get '/basic_auth_login' => 'sessions#basic_lookup'
    get '/logout' => 'sessions#destroy', :as => :logout
    post '/logout' => 'sessions#destroy', :as => :logout_post, :via => :post
  else
    post '/logout' => 'sessions#destroy', :as => :logout, :via => :post
  end

  # Act-as endpoints
  post '/act_as' => 'act_as#start', :via => :post
  post '/stop_act_as' => 'act_as#stop', :via => :post
  get '/stored_users' => 'stored_users#get', :via => :get, :defaults => { :format => 'json' }
  post '/store_user/saved' => 'stored_users#store_saved_uid', via: :post, defaults: { format: 'json' }
  post '/delete_user/saved' => 'stored_users#delete_saved_uid', via: :post, defaults: { format: 'json' }

  # All the other paths should use the bootstrap page
  # We need this because we use html5mode=true
  #
  # This should ALWAYS be the last rule on the routes list!
  get '/*url' => 'bootstrap#index', :defaults => { :format => 'html' }
end
