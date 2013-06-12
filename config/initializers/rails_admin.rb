# RailsAdmin config file.
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|

  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['CalCentral', 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # RailsAdmin may need a way to know who the current user is]
  # config.current_user_method { current_adminuser } # auto-generated

  # We're not using Devise or Warden for RailsAdmin authentication; check for superuser in authorize_with instead.
  config.authenticate_with {}

  config.authorize_with do
    redirect_to main_app.root_path unless UserAuth.is_superuser?(session[:user_id])
  end

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
  config.included_models = ['Link', 'LinkCategory', 'LinkSection', 'UserRole']

  # Label methods for model instances:
  # config.label_methods << :description # Default is [:name, :title]

  # config.model Link do
  # end


  ################  Model configuration  ################

  # Each model configuration can alternatively:
  #   - stay here in a `config.model 'ModelName' do ... end` block
  #   - go in the model definition file in a `rails_admin do ... end` block

  # This is your choice to make:
  #   - This initializer is loaded once at startup (modifications will show up when restarting the application) but all RailsAdmin configuration would stay in one place.
  #   - Models are reloaded at each request in development mode (when modified), which may smooth your RailsAdmin development workflow.
  #

  config.model 'LinkSection' do
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
      "#{self.link_root_cat.name}/#{self.link_top_cat.name}/#{self.link_sub_cat.name}"
    end
  end

  config.model 'LinkCategory' do
    label "Category"
  end

# UserRole needs to be available so we can set perms on Links, but should not be in left nav
  config.model 'UserRole' do
    visible false
  end

  config.model 'Link' do
    label "Link"
  end

  config.navigation_static_label = "Tools"

  config.navigation_static_links = {
    'Expire Campus Links Cache' => '/api/my/campuslinks/expire'
  }

end
