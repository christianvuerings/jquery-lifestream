# RailsAdmin config file.
# See github.com/sferik/rails_admin for more informations

# simple adapter class from our User::UserAuthPolicy (which is pundit-based) to CanCan, which is greatly preferred by rails_admin.
class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :access, :all
      can :dashboard, :all
      if user.policy.can_administrate?
        can :manage, [User::Auth]
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
      policy = User::Auth.get(session[:user_id]).policy
      redirect_to main_app.root_path unless policy.can_author?
    else
      redirect_to main_app.reauth_admin_path
    end
  }

  config.current_user_method {
    User::Auth.get(session[:user_id])
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
  config.included_models = ['Links::Link', 'Links::LinkCategory', 'Links::LinkSection', 'User::Auth', 'Links::UserRole']

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
    label "Section"

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
    label "Category"
  end

  # Links::UserRole needs to be available so we can set perms on Links, but should not be in left nav
  config.model 'Links::UserRole' do
    visible false
  end

  config.model 'Links::Link' do
    label "Link"
  end

  config.model 'User::Auth' do
    label "User Authorizations"
  end

  config.navigation_static_label = "Tools"

  config.navigation_static_links = {
    'Expire Campus Links Cache' => '/api/my/campuslinks/expire'
  }

end
