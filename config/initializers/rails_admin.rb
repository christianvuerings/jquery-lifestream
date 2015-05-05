# RailsAdmin config file.
# See github.com/sferik/rails_admin for more information.

# simple adapter class from our AuthenticationStatePolicy (which is pundit-based) to CanCan, which is greatly preferred by rails_admin.
class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :access, :all
      can :dashboard, :all
      if user.policy.can_administrate?
        can :manage, [User::Auth, Finaid::FinAidYear, Calendar::User, Calendar::QueuedEntry, Calendar::LoggedEntry, Calendar::Job, MailingLists::SiteMailingList]
      end
      if user.policy.can_author?
        can :manage, [Links::Link, Links::LinkCategory, Links::LinkSection, Links::UserRole]
      end
    end
  end
end

RailsAdmin.config do |config|

  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['CalCentral', 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # We're not using Devise or Warden for RailsAdmin authentication; check for superuser in authorize_with instead.
  config.authenticate_with {
    if cookies[:reauthenticated] || !!Settings.features.reauthentication == false
      policy = AuthenticationState.new(session).policy
      redirect_to main_app.root_path unless policy.can_author?
    else
      redirect_to main_app.reauth_admin_path
    end
  }

  # Because CanCan is not inheriting current_user from ApplicationController, we redefine it.
  config.current_user_method {
    AuthenticationState.new(session)
  }

  config.authorize_with :cancan

  # If you want to track changes on your models:
  # config.audit_with :history, 'Adminuser'

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, 'User'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  config.default_items_per_page = 50

  # Exclude specific models (keep the others):
  # config.excluded_models = ['OracleDatabase']

  # Include specific models (exclude the others):
  config.included_models = ['Links::Link', 'Links::LinkCategory', 'Links::LinkSection', 'Links::UserRole',
                            'Finaid::FinAidYear', 'User::Auth',
                            'Calendar::User', 'Calendar::QueuedEntry', 'Calendar::LoggedEntry', 'Calendar::Job',
                            'MailingLists::SiteMailingList']

  # Label methods for model instances:
  # config.label_methods << :description # Default is [:name, :title]

  # config.model Links::Link do
  # end


  ################  Model configuration  ################

  # Each model configuration can alternatively:
  #   - stay here in a `config.model 'ModelName' do ... end` block
  #   - go in the model definition file in a `rails_admin do ... end` block

  # This is your choice to make:
  #   - This initializer is loaded once at startup (modifications will show up when restarting the application) but all RailsAdmin configuration would stay in one place.
  #   - Models are reloaded at each request in development mode (when modified), which may smooth your RailsAdmin development workflow.
  #

  config.model 'Links::LinkSection' do
    label 'Section'

    object_label_method do
      :link_section_label_method
    end

    field :link_root_cat do
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.where(root_level: true)
        }
      end
    end

    field :link_top_cat
    field :link_sub_cat

  end

# Represent instances of the Linksection model as:
  def link_section_label_method
    if self.id
      "#{self.link_root_cat.try(:name)}/#{self.link_top_cat.try(:name)}/#{self.link_sub_cat.try(:name)}"
    end
  end

  config.model 'Links::LinkCategory' do
    label 'Category'
  end

  # Links::UserRole needs to be available so we can set perms on Links, but should not be in left nav
  config.model 'Links::UserRole' do
    visible false
  end

  config.model 'Links::Link' do
    label 'Link'
  end

  config.model 'User::Auth' do
    label 'User Authorizations'
    list do
      field :uid do
        column_width 60
      end
      field :is_superuser do
        column_width 20
      end
      field :is_author do
        column_width 20
      end
      field :is_viewer do
        column_width 20
      end
      field :active do
        column_width 20
      end
      field :created_at do
        column_width 130
      end
      field :updated_at do
        column_width 130
      end
    end
  end

  config.model 'Finaid::FinAidYear' do
    label 'Financial Aid Transition Dates'
  end

  config.model 'Calendar::User' do
    label 'Class Calendar Whitelist'
  end

  config.model 'Calendar::Job' do
    label 'Class Calendar Jobs'
  end

  config.model 'Calendar::QueuedEntry' do
    label 'Class Calendar Queue'
    list do
      field :year do
        column_width 50
      end
      field :term_cd do
        column_width 20
      end
      field :ccn do
        column_width 50
      end
      field :multi_entry_cd do
        column_width 20
      end
      field :transaction_type do
        column_width 20
      end
    end
  end

  config.model 'Calendar::LoggedEntry' do
    label 'Class Calendar Log'
    list do
      field :year do
        column_width 50
      end
      field :term_cd do
        column_width 20
      end
      field :ccn do
        column_width 50
      end
      field :multi_entry_cd do
        column_width 20
      end
      field :transaction_type do
        column_width 20
      end
      field :job_id do
        column_width 50
      end
      field :has_error do
        column_width 50
        pretty_value do
          value ? 'yes' : ''
        end
      end
    end
  end

  config.model 'MailingLists::SiteMailingList' do
    label 'Site Mailing List'
  end

  config.navigation_static_label = 'Tools'

  config.navigation_static_links = {
    'Expire Campus Links Cache' => '/api/my/campuslinks/expire'
  }

end
