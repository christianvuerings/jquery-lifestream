module MailingLists
  class SiteMailingList < ActiveRecord::Base
    include ActiveRecordHelper
    include ClassLogger
    include DatedFeed

    self.table_name = 'canvas_site_mailing_lists'

    attr_accessible :canvas_site_id, :list_name, :state, :populated_at
    attr_accessor :bad_request_error
    attr_accessor :population_results

    validates :bad_request_error, absence: true
    validates :canvas_site_id, uniqueness: true
    validates :list_name, uniqueness: true
    validates :list_name, format: {with: /\A[\w-]+\Z/, message: 'Only lowercase, numeric, underscore and hyphen characters are permitted.'}

    after_initialize :get_canvas_site
    after_initialize :init_unregistered, if: :new_record?

    before_create { self.state = 'pending' }

    after_find { check_for_creation if self.state == 'pending' }

    def populate
      if self.state != 'created'
        self.bad_request_error = "Mailing list \"#{self.list_name}\" must be created before being populated."
        return {error: bad_request_error}
      end

      course_users = Canvas::CourseUsers.new(course_id: self.canvas_site_id).course_users
      list_members = Calmail::ListMembers.new.list_members self.list_name

      if !course_users
        self.bad_request_error = "Could not retrieve current site roster for \"#{self.list_name}\"."
        {error: bad_request_error}
      elsif !list_members[:response] || !list_members[:response][:addresses]
        self.bad_request_error = "Could not retrieve existing list roster for \"#{self.list_name}\"."
        {error: bad_request_error}
      else
        update_memberships(course_users, list_members[:response][:addresses])
        self.population_results
      end
    end

    def to_json
      feed = {
        canvasSite: {
          canvasCourseId: self.canvas_site_id
        }
      }
      if @canvas_site
        feed[:canvasSite].merge!({
          sisCourseId: @canvas_site['sis_course_id'],
          name: @canvas_site['name'],
          courseCode: @canvas_site['course_code'],
          url: "#{Settings.canvas_proxy.url_root}/courses/#{@canvas_site['id']}",
          term: parse_term(@canvas_site['term'])
        })
        feed[:mailingList] = {
          name: self.list_name,
          domain: Settings.calmail_proxy.domain,
          state: self.state
        }
        feed[:mailingList][:creationUrl] = build_creation_url if self.state == 'pending'
        feed[:mailingList][:timeLastPopulated] = format_date(self.populated_at) if self.populated_at
        feed[:populationResults] = population_results if population_results.present?
      end
      if bad_request_error
        feed[:displayError] = 'badRequest'
        feed[:badRequestError] = bad_request_error
      elsif errors.any?
        feed[:displayError] = 'badRequest'
        feed[:validationErrors] = errors
      end
      feed.to_json
    end

    private

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
      Settings.calmail_proxy.base_url.sub(/api1\Z/, "list/domain_create_list2?#{params.to_param}")
    end

    def check_for_creation
      self.state = 'created' if !name_available?
    end

    def generate_list_name
      # 'CHEM 1A LEC 003' => 'chem_1a_lec_003-sp15'
      # {{design}} => 'design-sp15'
      # 'The "Wild"-"Wild" West?' => 'the_wild_wild_west-sp15'
      # 'Conversation intermédiaire' => 'conversation_intermediaire-sp15'
      if @canvas_site
        normalized_name = I18n.transliterate(@canvas_site['name']).downcase.split(/[^a-z0-9]+/).reject(&:blank?).join('_')
        term = Canvas::Proxy.sis_term_id_to_term(@canvas_site['term']['sis_term_id'])
        "#{normalized_name}-#{Berkeley::TermCodes.to_abbreviation(term[:term_yr], term[:term_cd])}"
      end
    end

    def get_canvas_site
      return if self.canvas_site_id.blank?
      unless (@canvas_site = Canvas::Course.new(canvas_course_id: self.canvas_site_id).course)
        self.bad_request_error = "No bCourses site found with ID \"#{self.canvas_site_id}\"."
      end
    end

    def init_unregistered
      self.state = 'unregistered'
      self.list_name ||= generate_list_name
      if !name_available?
        self.bad_request_error = "Mailing list name \"#{self.list_name}\" is already taken."
      end
    end

    def name_available?
      if (check_namespace = Calmail::CheckNamespace.new.name_available? self.list_name)
        check_namespace[:response]
      end
    end

    def parse_term(term)
      if (parsed_term = Canvas::Proxy.sis_term_id_to_term(term['sis_term_id']))
        parsed_term.merge(name: Berkeley::TermCodes.to_english(parsed_term[:term_yr], parsed_term[:term_cd]))
      end
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
          user_address = user['email_address'].downcase
          addresses_to_remove.delete user_address
          unless list_address_set.include? user_address
            population_results[:add][:total] += 1
            proxy_response = add_member_proxy.add_member(self.list_name, user_address, "#{user['first_name']} #{user['last_name']}")
            if proxy_response[:response] && proxy_response[:response][:added]
              population_results[:add][:success] += 1
            else
              population_results[:add][:failure] << user_address
            end
          end
        end
      end

      logger.info "Added #{population_results[:add][:success]} of #{population_results[:add][:total]} new site members."
      if population_results[:add][:failure].any?
        logger.error "Failed to add #{population_results[:add][:failure].count} addresses to #{self.list_name}: #{population_results[:add][:failure].join(' , ')}"
      end

      remove_member_proxy = Calmail::RemoveListMember.new
      population_results[:remove][:total] = addresses_to_remove.count

      addresses_to_remove.each do |address|
        proxy_response = remove_member_proxy.remove_member(self.list_name, address)
        if proxy_response[:response] && proxy_response[:response][:removed]
          population_results[:remove][:success] += 1
        else
          population_results[:remove][:failure] << address
        end
      end

      logger.info "Removed #{population_results[:remove][:success]} of #{population_results[:remove][:total]} former site members."
      if population_results[:remove][:failure].any?
        logger.error "Failed to remove #{population_results[:remove][:failure].count} addresses from #{self.list_name}: #{population_results[:remove][:failure].join(' , ')}"
      end

      logger.info "Finished population of mailing list #{self.list_name}."
      self.populated_at = DateTime.now
      save
    end

  end
end
