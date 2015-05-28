module MailingLists
  class SiteMailingList < ActiveRecord::Base
    include ActiveRecordHelper
    include ClassLogger
    include DatedFeed

    self.table_name = 'canvas_site_mailing_lists'

    attr_accessible :canvas_site_id, :list_name, :state, :members_count, :populated_at, :populate_add_errors, :populate_remove_errors
    attr_accessor :request_failure
    attr_accessor :population_results

    validate :catch_request_failure

    validates :canvas_site_id, presence: {message: 'ID must be a numeric string.'}
    validates :canvas_site_id, uniqueness: {message: 'ID "%{value}" has already reserved a mailing list.'}

    validates :list_name, uniqueness: {message: '"%{value}" has already been reserved.'}
    validates :list_name, format: {
      with: /\A[\w-]+\Z/,
      message: 'may contain only lowercase, numeric, underscore and hyphen characters.',
      allow_blank: true
    }
    validates :list_name, length: {
      minimum: 2,
      maximum: 50,
      message: 'must be between 2 and 50 characters in length.',
      allow_blank: true
    }

    after_initialize :get_canvas_site, if: :new_record?
    after_initialize :init_unregistered, if: :new_record?

    before_create { self.state = 'pending' }

    after_find { check_for_creation if self.state == 'pending' }

    def populate
      if self.state != 'created'
        self.request_failure = "Mailing list \"#{self.list_name}\" must be created before being populated."
        return
      end

      course_users = Canvas::CourseUsers.new(course_id: self.canvas_site_id).course_users
      list_members = get_member_addresses

      if !course_users
        self.request_failure = "Could not retrieve current site roster for \"#{self.list_name}\"."
      elsif !list_members
        self.request_failure = "Could not retrieve existing list roster for \"#{self.list_name}\"."
      else
        update_memberships(course_users, list_members)
      end
    end

    def to_json
      feed = {}
      get_canvas_site
      if @canvas_site
        feed[:canvasSite] = {
          canvasCourseId: self.canvas_site_id,
          sisCourseId: @canvas_site['sis_course_id'],
          name: @canvas_site['name'],
          courseCode: @canvas_site['course_code'],
          url: "#{Settings.canvas_proxy.url_root}/courses/#{@canvas_site['id']}",
          term: parse_term(@canvas_site['term'])
        }
        feed[:mailingList] = {
          name: self.list_name,
          domain: Settings.calmail_proxy.domain,
          state: self.state
        }
        feed[:mailingList][:creationUrl] = build_creation_url if self.state == 'pending'
        feed[:mailingList][:administrationUrl] = build_administration_url if self.state == 'created'
        if self.populated_at.present?
          feed[:mailingList][:membersCount] = self.members_count
          feed[:mailingList][:timeLastPopulated] = format_date(self.populated_at.to_datetime)
          if self.population_results || self.populate_add_errors.try(:nonzero?) || self.populate_remove_errors.try(:nonzero?)
            feed[:populationResults] = population_results_for_feed
          end
        end
      end
      feed[:errorMessages] = errors.full_messages if invalid?
      feed.to_json
    end

    private

    def any_population_failures?
      self.population_results[:add][:failure].any? || self.population_results[:remove][:failure].any?
    end

    def build_administration_url
      Settings.calmail_proxy.base_url.sub(
        /api1\Z/,
        "list/listinfo/#{self.list_name}%40#{Settings.calmail_proxy.domain}"
      )
    end

    def build_creation_url
      params = {
        domain_name: Settings.calmail_proxy.domain,
        listname: self.list_name,
        owner_address: Settings.calmail_proxy.owner_address,
        advertised: 0,
        subscribe_policy: 3,
        moderate: 0,
        generic_nonmember_action: 1
      }
      Settings.calmail_proxy.base_url.sub(/api1\Z/, "list/domain_create_list2?#{params.to_query}")
    end

    def catch_request_failure
      errors[:base] << self.request_failure if self.request_failure
    end

    def check_for_creation
      self.state = 'created' if name_available? == false
    end

    def generate_list_name
      # 'CHEM 1A LEC 003' => 'chem_1a_lec_003-sp15'
      # {{design}} => 'design-sp15'
      # 'The "Wild"-"Wild" West?' => 'the_wild_wild_west-sp15'
      # 'Conversation intermédiaire' => 'conversation_intermediaire-sp15'
      # 'Global Health: Disaster Preparedness and Response' => 'global_health_disaster_preparedness_and_respo-sp15'
      if @canvas_site
        normalized_name = I18n.transliterate(@canvas_site['name']).downcase.split(/[^a-z0-9]+/).reject(&:blank?).join('_').slice(0, 45)
        if (term = Canvas::Proxy.sis_term_id_to_term @canvas_site['term']['sis_term_id'])
          normalized_name << "-#{Berkeley::TermCodes.to_abbreviation(term[:term_yr], term[:term_cd])}"
        end
        normalized_name
      end
    end

    def get_canvas_site
      return if self.canvas_site_id.blank? || @canvas_site
      unless (@canvas_site = Canvas::Course.new(canvas_course_id: self.canvas_site_id).course)
        self.request_failure = "No bCourses site with ID \"#{self.canvas_site_id}\" was found."
      end
    end

    def get_member_addresses
      if (list_members = Calmail::ListMembers.new.list_members self.list_name)
        list_members[:response] && list_members[:response][:addresses]
      end
    end

    def init_unregistered
      self.state = 'unregistered'
      get_canvas_site
      self.list_name ||= generate_list_name
      if name_available? == false
        self.request_failure = "Mailing list name \"#{self.list_name}\" is already taken."
      end
    end

    def name_available?
      if (check_namespace = Calmail::CheckNamespace.new.name_available? self.list_name) &&
          (check_namespace[:response] == true || check_namespace[:response] == false)
        check_namespace[:response]
      else
        self.request_failure = 'There was an error connecting to Calmail.'
        nil
      end
    end

    def parse_term(term)
      if (parsed_term = Canvas::Proxy.sis_term_id_to_term(term['sis_term_id']))
        parsed_term.merge(name: Berkeley::TermCodes.to_english(parsed_term[:term_yr], parsed_term[:term_cd]))
      end
    end

    def population_results_for_feed
      messages = []
      if self.population_results
        success = population_results[:add][:failure].empty? && population_results[:remove][:failure].empty?
        if success
          messages << population_results_to_english(
            [population_results[:add][:success], 'added', true],
            [population_results[:remove][:success], 'removed', true]
          )
        else
          messages << population_results_to_english(
            [population_results[:add][:failure].count, 'added', false],
            [population_results[:remove][:failure].count, 'removed', false]
          )
        end
      elsif self.populate_add_errors.nonzero? || self.populate_remove_errors.nonzero?
        messages << population_results_to_english(
          [self.populate_add_errors, 'added', false],
          [self.populate_remove_errors, 'removed', false]
        )
        success = false
      end
      {
        success: success,
        messages: messages.compact
      }
    end

    def population_results_to_english(*components)
      english_components = components.map do |component|
        count, action, success = component
        next if count.zero?
        message = "#{count} "
        message << (action == 'added' ? 'new' : 'former')
        message << ' member'
        message << 's' if count > 1
        if success
          message << (count > 1 ? ' were ' : ' was ')
        else
          message << ' could not be '
        end
        message << action
      end
      english_components.compact!
      english_components.join('; ').concat('.') if english_components.any?
    end

    def update_memberships(course_users, list_addresses)
      self.population_results = {
        add: {
          total: 0,
          success: 0,
          failure: []
        },
        remove: {
          total: 0,
          success: 0,
          failure: []
        }
      }
      list_address_set = list_addresses.to_set
      addresses_to_remove = list_address_set.clone

      logger.info "Starting population of mailing list #{self.list_name} for course site #{self.canvas_site_id}."

      add_member_proxy = Calmail::AddListMember.new

      course_users.map{ |user| user['login_id'] }.each_slice(1000) do |uid_slice|
        user_slice = CampusOracle::Queries.get_basic_people_attributes uid_slice
        user_slice.each do |user|
          if (user_address = user['email_address'])
            user_address.downcase!
            addresses_to_remove.delete user_address
            unless list_address_set.include? user_address
              population_results[:add][:total] += 1
              logger.debug "Adding address #{user_address}"
              proxy_response = add_member_proxy.add_member(self.list_name, user_address, "#{user['first_name']} #{user['last_name']}")
              if proxy_response[:response] && proxy_response[:response][:added]
                population_results[:add][:success] += 1
              else
                population_results[:add][:failure] << user_address
              end
            end
          else
            logger.warn "No email address found for UID #{user['ldap_uid']}"
          end
        end
      end

      remove_member_proxy = Calmail::RemoveListMember.new
      population_results[:remove][:total] = addresses_to_remove.count

      addresses_to_remove.each do |address|
        logger.debug "Removing address #{address}"
        proxy_response = remove_member_proxy.remove_member(self.list_name, address)
        if proxy_response[:response] && proxy_response[:response][:removed]
          population_results[:remove][:success] += 1
        else
          population_results[:remove][:failure] << address
        end
      end

      # The Calmail API may successfully update memberships without returning a success response, so do
      # a post-update check on any failures to see if they were real failures.
      if any_population_failures? && (addresses_after_update = get_member_addresses)
        address_set = addresses_after_update.to_set
        population_results[:add][:failure].reject! { |address| address_set.include? address }
        population_results[:remove][:failure].reject! { |address| !address_set.include? address }
        population_results[:add][:success] = population_results[:add][:total] - population_results[:add][:failure].count
        population_results[:remove][:success] = population_results[:remove][:total] - population_results[:remove][:failure].count
        self.members_count = address_set.count
      else
        self.members_count = list_address_set.count + population_results[:add][:success] - population_results[:remove][:success]
      end

      logger.info "Added #{population_results[:add][:success]} of #{population_results[:add][:total]} new site members."
      if population_results[:add][:failure].any?
        logger.error "Failed to add #{population_results[:add][:failure].count} addresses to #{self.list_name}: #{population_results[:add][:failure].join(' , ')}"
      end

      logger.info "Removed #{population_results[:remove][:success]} of #{population_results[:remove][:total]} former site members."
      if population_results[:remove][:failure].any?
        logger.error "Failed to remove #{population_results[:remove][:failure].count} addresses from #{self.list_name}: #{population_results[:remove][:failure].join(' , ')}"
      end

      logger.info "Finished population of mailing list #{self.list_name}."
      self.populate_add_errors = population_results[:add][:failure].count
      self.populate_remove_errors = population_results[:remove][:failure].count
      self.populated_at = DateTime.now
      save
    end

  end
end
