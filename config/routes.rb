Calcentral::Application.routes.draw do

  mount RailsAdmin::Engine => '/ccadmin', :as => 'rails_admin'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  root :to => 'bootstrap#index'

  # Rails API endpoints.
  get '/api/my/am_i_logged_in' => 'user_api#am_i_logged_in', :as => :am_i_logged_in, :defaults => { :format => 'json' }
  get '/api/my/status' => 'user_api#mystatus', :as => :mystatus, :defaults => { :format => 'json' }
  get '/api/my/classes' => 'my_classes#get_feed', :as => :my_classes, :defaults => { :format => 'json' }
  get '/api/my/textbooks_details' => 'my_textbooks#get_feed', :as => :my_textbooks, :defaults => { :format => 'json' }
  post '/api/my/record_first_login' => 'user_api#record_first_login', :as => :record_first_login, :defaults => { :format => 'json' }, :via => :post
  get '/api/my/up_next' => 'my_up_next#get_feed', :as => :my_up_next, :defaults => { :format => 'json' }
  post '/api/my/tasks/create' => 'my_tasks#insert_task', :via => :post, :as => :insert_task, :defaults => { :format => 'json' }
  post '/api/my/tasks/clear_completed' => 'my_tasks#clear_completed_tasks', :via => :post, :as => :clear_completed_tasks, :defaults => { :format => 'json' }
  post '/api/my/tasks/delete/:task_id' => 'my_tasks#delete_task', :via => :post, :as => :delete_task, :defaults => { :format => 'json' }
  get '/api/my/tasks' => 'my_tasks#get_feed', :via => :get, :as => :my_tasks, :defaults => { :format => 'json' }
  post '/api/my/tasks' => 'my_tasks#update_task', :via => :post, :as => :update_task, :defaults => { :format => 'json' }
  get '/api/my/groups' => 'my_groups#get_feed', :as => :my_groups, :defaults => { :format => 'json' }
  get '/api/my/activities' => 'my_activities#get_feed', :as => :my_activities, :defaults => { :format => 'json' }
  get '/api/my/badges' => 'my_badges#get_feed', :as => :my_badges, :defaults => { :format => 'json' }
  get '/api/my/academics' => 'my_academics#get_feed', :as => :my_academics, :defaults => { :format => 'json' }
  get '/api/my/financials' => 'my_financials#get_feed', :as => :my_financials, :defaults => {:format => 'json'}
  get '/api/my/cal1card' => 'my_cal1card#get_feed', :as => :my_cal1card, :defaults => {:format => 'json'}
  get '/api/my/campuslinks' => 'my_campus_links#get_feed', :as => :my_campus_links, :defaults => { :format => 'json' }
  get '/api/my/campuslinks/expire' => 'my_campus_links#expire'
  get '/api/my/refresh' => 'my_refresh#refresh', :defaults => { :format => 'json' }
  get '/api/my/updated_feeds' => 'is_updated#list', :defaults => {:format => 'json'}
  post '/api/my/event' => 'my_events#create', via: :post, defaults: { format: 'json' }

  # Youtube class videos endpoints
  ## Get the playlist_id of the title given, or list all playlists if no title given.
  get '/api/my/playlists(/:playlist_title)' => 'my_playlists#get_playlists', :defaults => { :format => 'json' }
  ## Get a list of youtube videos given a playlist_id.
  get '/api/my/youtube/:playlist_id' => 'my_youtube#get_videos', :defaults => { :format => 'json' }
  ## Get a list of youtube videos given a playlist_title.
  get '/api/my/media/:playlist_title' => 'my_media#get_media', :constraints => { :playlist_title => /[^\/]+/ }, :defaults => { :format => 'json' }

  # Canvas embedded application support.
  post '/canvas/embedded/*url' => 'canvas_lti#embedded', :defaults => { :format => 'html' }
  get '/canvas/lti_roster_photos' => 'canvas_lti#lti_roster_photos', :defaults => { :format => 'xml' }
  get '/canvas/lti_course_provision_account_navigation' => 'canvas_lti#lti_course_provision_account_navigation', :defaults => { :format => 'xml' }
  get '/canvas/lti_course_provision_user_navigation' => 'canvas_lti#lti_course_provision_user_navigation', :defaults => { :format => 'xml' }
  get '/canvas/lti_user_provision' => 'canvas_lti#lti_user_provision', :defaults => { :format => 'xml' }
  get '/canvas/lti_course_add_user' => 'canvas_lti#lti_course_add_user', :defaults => { :format => 'xml' }

  # A Canvas course ID of "embedded" means to retrieve from session properties.
  get '/api/academics/canvas/course_user_profile' => 'canvas#course_user_profile', :defaults => { :format => 'json' }
  get '/api/academics/canvas/external_tools' => 'canvas#external_tools', :defaults => { :format => 'json' }
  get '/api/academics/rosters/canvas/:canvas_course_id' => 'canvas_rosters#get_feed', :as => :canvas_roster, :defaults => { :format => 'json' }
  get '/api/academics/rosters/campus/:campus_course_id' => 'campus_rosters#get_feed', :as => :campus_roster, :defaults => { :format => 'json' }
  get '/canvas/:canvas_course_id/photo/:person_id' => 'canvas_rosters#photo', :defaults => { :format => 'jpeg' }, :action => 'show'
  get '/campus/:campus_course_id/photo/:person_id' => 'campus_rosters#photo', :defaults => { :format => 'jpeg' }, :action => 'show'
  get '/api/academics/canvas/course_provision' => 'canvas_course_provision#get_feed', :as => :canvas_course_provision, :defaults => { :format => 'json' }
  get '/api/academics/canvas/course_provision_as/:admin_acting_as' => 'canvas_course_provision#get_feed', :as => :canvas_course_provision_as, :defaults => { :format => 'json' }
  post '/api/academics/canvas/course_provision/create' => 'canvas_course_provision#create_course_site', :via => :post, :as => :canvas_course_create, :defaults => { :format => 'json' }
  get '/api/academics/canvas/course_provision/status' => 'canvas_course_provision#job_status', :via => :get, :as => :canvas_course_job_status, :defaults => { :format => 'json' }
  post '/api/academics/canvas/user_provision/user_import' => 'canvas_user_provision#user_import', :as => :canvas_user_provision_import, :defaults => { :format => 'json' }
  get '/api/academics/canvas/course_add_user/search_users' => 'canvas_course_add_user#search_users', :via => :get, :as => :canvas_course_add_user_search_users, :defaults => { :format => 'json' }
  get '/api/academics/canvas/course_add_user/course_sections' => 'canvas_course_add_user#course_sections', :via => :get, :as => :canvas_course_add_user_course_sections, :defaults => { :format => 'json' }
  post '/api/academics/canvas/course_add_user/add_user' => 'canvas_course_add_user#add_user', :via => :post, :as => :canvas_course_add_user_add_user, :defaults => { :format => 'json' }

  get '/api/smoke_test_routes' => 'routes_list#smoke_test_routes', :as => :all_routes, :defaults => { :format => 'json' }

  get '/api/blog' => 'blog_feed#get_blog_info', :as => :blog_info, :defaults => { :format => 'json' }

  post '/api/my/opt_out'=> 'user_api#delete', :via => :post
  get '/api/clear_cache' => 'application#clear_cache'
  get '/api/ping' => 'application#ping', :defaults => {:format => 'json'}
  get '/api/refresh_logging' => 'refresh_logging#refresh_logging', :defaults => { :format => 'json' }

  get '/api/canvas/request_authorization' => 'canvas_auth#request_authorization'
  get '/canvas/oAuthResponse' => 'canvas_auth#handle_callback'
  post '/api/canvas/remove_authorization' => 'canvas_auth#remove_authorization', :via => :post

  get '/api/google/request_authorization'=> 'google_auth#request_authorization'
  get '/api/google/handle_callback' => 'google_auth#handle_callback'
  post '/api/google/remove_authorization' => 'google_auth#remove_authorization', :via => :post
  post '/api/google/dismiss_reminder' => 'google_auth#dismiss_reminder', :defaults => { :format => 'json'}, :via => :post

  get '/api/tools/styles' => 'tools#get_styles', :via => :get

  get '/api/server_info' => 'server_runtime#get_info', :via => :get
  get '/api/stats' => 'stats#get_stats', :via => :get, :defaults => { :format => 'json' }

  get '/auth/cas/callback' => 'sessions#lookup'
  get '/auth/failure' => 'sessions#failure'
  if Settings.developer_auth.enabled
    get '/basic_auth_login' => 'sessions#basic_lookup'
    get '/logout' => 'sessions#destroy', :as => :logout
    post '/logout' => 'sessions#destroy', :as => :logout_post, :via => :post
  else
    post '/logout' => 'sessions#destroy', :as => :logout, :via => :post
  end

  post '/act_as' => 'sessions#act_as', :via => :post
  post '/stop_act_as' => 'sessions#stop_act_as', :via => :post

  get '/api/search_users/:id' => 'search_users#search_users', :via => :get, :defaults => { :format => 'json' }

  # All the other paths should use the bootstrap page
  # We need this because we use html5mode=true
  #
  # This should ALWAYS be the last rule on the routes list!
  get '/*url' => 'bootstrap#index', :defaults => { :format => 'html' }
end
