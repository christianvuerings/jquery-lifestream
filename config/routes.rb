Calcentral::Application.routes.draw do

  mount RailsAdmin::Engine => '/ccadmin', :as => 'rails_admin'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  root :to => 'bootstrap#index'

  # Rails API endpoints.
  match '/api/my/status' => 'user_api#mystatus', :as => :mystatus, :defaults => { :format => 'json' }
  match '/api/my/classes' => 'my_classes#get_feed', :as => :my_classes, :defaults => { :format => 'json' }
  match '/api/my/record_first_login' => 'user_api#record_first_login', :as => :record_first_login, :defaults => { :format => 'json' }, :via => :post
  match '/api/my/up_next' => 'my_up_next#get_feed', :as => :my_up_next, :defaults => { :format => 'json' }
  match '/api/my/tasks/create' => 'my_tasks#insert_task', :via => :post, :as => :insert_task, :defaults => { :format => 'json' }
  match '/api/my/tasks/clear_completed' => 'my_tasks#clear_completed_tasks', :via => :post, :as => :clear_completed_tasks, :defaults => { :format => 'json' }
  match '/api/my/tasks/delete/:task_id' => 'my_tasks#delete_task', :via => :post, :as => :delete_task, :defaults => { :format => 'json' }
  match '/api/my/tasks' => 'my_tasks#get_feed', :via => :get, :as => :my_tasks, :defaults => { :format => 'json' }
  match '/api/my/tasks' => 'my_tasks#update_task', :via => :post, :as => :update_task, :defaults => { :format => 'json' }
  match '/api/my/groups' => 'my_groups#get_feed', :as => :my_groups, :defaults => { :format => 'json' }
  match '/api/my/activities' => 'my_activities#get_feed', :as => :my_activities, :defaults => { :format => 'json' }
  match '/api/my/badges' => 'my_badges#get_feed', :as => :my_badges, :defaults => { :format => 'json' }
  match '/api/my/academics' => 'my_academics#get_feed', :as => :my_academics, :defaults => { :format => 'json' }
  match '/api/my/campuslinks' => 'my_campus_links#get_feed', :as => :my_campus_links, :defaults => { :format => 'json' }
  match '/api/my/campuslinks/expire' => 'my_campus_links#expire'
  match '/api/my/refresh' => 'my_refresh#refresh', :defaults => { :format => 'json' }

  match '/api/smoke_test_routes' => 'routes_list#smoke_test_routes', :as => :all_routes, :defaults => { :format => 'json' }

  match '/api/blog/release_notes/latest' => 'blog_feed#get_latest_release_notes', :as => :blog_latest_release_notes, :defaults => { :format => 'json' }

  match '/api/my/opt_out'=> 'user_api#delete', :via => :post
  match '/api/clear_cache' => 'application#clear_cache'

  match '/api/canvas/request_authorization' => 'canvas_auth#request_authorization'
  match '/canvas/oAuthResponse' => 'canvas_auth#handle_callback'
  match '/api/canvas/remove_authorization' => 'canvas_auth#remove_authorization', :via => :post

  match '/api/google/request_authorization'=> 'google_auth#request_authorization'
  match '/api/google/handle_callback' => 'google_auth#handle_callback'
  match '/api/google/remove_authorization' => 'google_auth#remove_authorization', :via => :post

  match '/api/tools/styles' => 'tools#get_styles', :via => :get

  match '/api/server_info' => 'server_runtime#get_info', :via => :get
  match '/api/stats' => 'stats#get_stats', :via => :get, :defaults => { :format => 'json' }

  match '/auth/cas/callback' => 'sessions#lookup'
  match '/auth/failure' => 'sessions#failure'
  if Settings.developer_auth.enabled
    match '/basic_auth_login' => 'sessions#basic_lookup'
    match '/logout' => 'sessions#destroy', :as => :logout
  else
    match '/logout' => 'sessions#destroy', :as => :logout, :via => :post
  end

  match '/login' => 'sessions#new', :as => :login

  match '/act_as' => 'sessions#act_as', :via => :post
  match '/stop_act_as' => 'sessions#stop_act_as', :via => :post

  # All the other paths should use the bootstrap page
  # We need this because we use html5mode=true
  #
  # This should ALWAYS be the last rule on the routes list!
  match '/*url' => 'bootstrap#index', :defaults => { :format => 'html' }
end
