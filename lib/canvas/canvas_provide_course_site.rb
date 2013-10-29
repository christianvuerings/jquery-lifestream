class CanvasProvideCourseSite < CanvasCsv
  include ClassLogger

  # Currently this depends on an instructor's point of view.
  # TODO Also support admin/superuser provisioning for sections which do not yet have an instructor assigned to them.
  def initialize(options = {})
    super()
    @uid = options[:user_id]
  end

  def course_site_url(sis_id)
    response = CanvasCourseProxy.new(course_id: sis_id).course
    raise RuntimeError, "Unexpected error obtaining course site URL for #{sis_id}!" if response.blank?
    course_data = JSON.parse(response.body)
    "#{Settings.canvas_proxy.url_root}/courses/#{course_data['id']}"
  end


  def current_terms
    @current_terms ||= Settings.canvas_proxy.current_terms_codes.collect do |term|
      {
          yr: term.term_yr,
          cd: term.term_cd,
          slug: TermCodes.to_slug(term.term_yr, term.term_cd)
      }
    end
  end

  def find_term(term_slug)
    term_index = current_terms.index {|term| term[:slug] == term_slug}
    raise ArgumentError, "term_slug does not match current term code" if term_index.nil?
    current_terms[term_index]
  end

  def candidate_courses_list
    terms_filter = current_terms

    # Get all sections for which this user is an instructor, sorted in a useful fashion.
    # TODO Add nested sections.
    # TODO Add pointers to existing bCourses sites.
    # Since this happens to match what's shown by MyAcademics::Teaching for a given semester,
    # we can simply re-use the academics feed (so long as course site provisioning is restricted to
    # semesters supported by My Academics). Ideally, MyAcademics::Teaching would be efficiently cached
    # by user_id + term_yr + term_cd. But since we currently only cache at the level of the full
    # merged model, we're probably better off selecting the desired teaching-semester from that bigger feed.

    academics_feed = MyAcademics::Merged.new(@uid).get_feed
    if (teaching_semesters = academics_feed[:teaching_semesters])
      teaching_semesters.select do |teaching_semester|
        terms_filter.index {|term| teaching_semester[:slug] == term[:slug]}
      end
    else
      []
    end
  end

  def create_course_site(term_slug, ccns)
    term = find_term(term_slug)

    # Check permissions. The user must have instructor access (direct or inherited via section-nesting) to all sections.
    campus_courses = filter_courses_by_ccns(candidate_courses_list, term_slug, ccns)

    # Derive course site SIS ID, course code (short name), and title from first section's course info.
    course_source = campus_courses[0]
    department = course_source[:dept]

    # Check that we have a departmental location for this course.
    subaccount = subaccount_for_department(department)

    # Create Canvas course site.
    # Because the course's term is not included in the "Create a new course" API, we must use CSV import.
    canvas_course_row = generate_course_site_definition(term[:yr], term[:cd], subaccount, course_source)

    sis_course_id = canvas_course_row['course_id']
    course_site_short_name = canvas_course_row['short_name']

    # Add Canvas course sections to match the source sections.
    # We could use the "Create course section" API, but to reduce API usage we instead use CSV import.
    canvas_section_rows = generate_section_definitions(term[:yr], term[:cd], canvas_course_row['course_id'], campus_courses)

    # Add current instructor so that link to course site will work.
    # TODO Need to skip this when we support direct administrative creation of course sites based on sections.
    # TODO Can eliminate this step if we import all official instructors for the sections.
    user_rows = accumulate_user_data([@uid], [])
    membership_rows = generate_course_memberships(canvas_section_rows, user_rows[0])

    outcome = import_course(canvas_course_row, canvas_section_rows, user_rows, membership_rows)
    return outcome if outcome[:created_status] == 'ERROR'

    # TODO Perform initial import of official campus instructors for these sections.
    # TODO Perform initial import of official campus student enrollments.

    found_url = course_site_url(sis_course_id)

    outcome['created_course_site_url'] = found_url
    outcome['created_course_site_short_name'] = course_site_short_name

    # TODO Expire user's Canvas-related caches to maintain UX consistency.
    outcome
  end

  def filter_courses_by_ccns(courses_list, term_slug, ccns)
    filtered = []
    idx = courses_list.index {|term| term[:slug] == term_slug}
    if idx.blank?
      logger.error("Specified term_slug '#{term_slug}' does not match current term code")
      raise ArgumentError, "No courses found!"
    end
    courses = courses_list[idx][:classes]
    courses.each do |course|
      filtered_sections = []
      course[:sections].each do |section|
        if ccns.include?(section[:ccn])
          filtered_sections << section
          ccns.delete(section[:ccn])
        end
      end
      if !filtered_sections.empty?
        course[:sections] = filtered_sections
        filtered << course
      end
    end
    logger.warn("User #{@uid} tried to provision inaccessible CCNs: #{ccns.inspect}") if ccns.any?
    filtered
  end

  # We add the instructor as a teacher in the default section of the course. This should
  # be enough to grant site access before a full campus data refresh is done.
  def generate_course_memberships(section_rows, instructor_row)
    enrollments = []
    section_rows.each do |section_row|
      enrollments << {
        'course_id' => section_row['course_id'],
        'user_id' => instructor_row['user_id'],
        'role' => 'teacher',
        'section_id' => section_row['section_id'],
        'status' => 'active'
      }
    end
    enrollments
  end

  def generate_course_site_definition(term_yr, term_cd, subaccount, campus_course_data)
    first_section = campus_course_data[:sections][0]
    course_name_short = "#{campus_course_data[:course_number]} #{first_section[:section_label]}"
    if (sis_id = generate_unique_sis_course_id(CanvasExistenceCheckProxy.new, campus_course_data[:slug], term_yr, term_cd))
      {
        'course_id' => sis_id,
        'short_name' => course_name_short,
        'long_name' => campus_course_data[:title],
        'account_id' => subaccount,
        'term_id' => CanvasProxy.term_to_sis_id(term_yr, term_cd),
        'status' => 'active'
      }
    else
      logger.error("Unable to generate unique Canvas course SIS ID for '#{course_name_short}'; will NOT create site")
      raise RuntimeError, "Could not define new course site!"
    end
  end

  def generate_section_definitions(term_yr, term_cd, sis_course_id, campus_section_data)
    raise ArgumentError, "'campus_section_data' argument is empty" if campus_section_data.empty?
    sections = []
    existence_proxy = CanvasExistenceCheckProxy.new
    campus_section_data.each do |course|
      course[:sections].each do |section|
        if (sis_section_id = generate_unique_sis_section_id(existence_proxy, section[:ccn], term_yr, term_cd))
          sections << {
            'section_id' => sis_section_id,
            'course_id' => sis_course_id,
            'name' => "#{course[:course_number]} #{section[:section_label]}",
            'status' => 'active'
          }
        else
          logger.error("Unable to generate unique Canvas section SIS ID for CCN #{section[:ccn]} in #{source}; will NOT create section")
        end
      end
    end
    sections
  end

  def generate_unique_sis_course_id(existence_proxy, slug, term_yr, term_cd)
    sis_id_root = "#{slug}-#{term_yr}-#{term_cd}"
    sis_id_suffix = ''
    sis_id = nil
    retriable(on: CanvasProvideCourseSite::IdNotUniqueException, tries: 20) do
      candidate = "CRS:#{sis_id_root}#{sis_id_suffix}".upcase
      if existence_proxy.course_defined?(candidate)
        logger.info("Already have Canvas course with SIS ID #{candidate}")
        sis_id_suffix = "-#{SecureRandom.hex(4)}"
        raise CanvasProvideCourseSite::IdNotUniqueException
      else
        sis_id = candidate
      end
    end
    sis_id
  end

  def generate_unique_sis_section_id(existence_proxy, ccn, term_yr, term_cd)
    sis_id_root = "#{term_yr}-#{term_cd}-#{ccn}"
    sis_id_suffix = ''
    sis_id = nil
    retriable(on: CanvasProvideCourseSite::IdNotUniqueException, tries: 20) do
      candidate = "SEC:#{sis_id_root}#{sis_id_suffix}".upcase
      if existence_proxy.section_defined?(candidate)
        logger.info("Already have Canvas section with SIS ID #{candidate}")
        sis_id_suffix = "-#{SecureRandom.hex(4)}"
        raise CanvasProvideCourseSite::IdNotUniqueException
      else
        sis_id = candidate
      end
    end
    sis_id
  end

  # TODO Upload a ZIP archive instead and do more detailed parsing of the import status.
  def import_course(canvas_course_row, canvas_section_rows, canvas_user_rows, canvas_enrollment_rows)
    uuid = SecureRandom.hex(8)
    filename_prefix = "#{@export_dir}/course_provision-#{DateTime.now.strftime('%F')}-#{uuid}"
    courses_csv_file = make_courses_csv("#{filename_prefix}-course.csv", [canvas_course_row])
    sections_csv_file = make_sections_csv("#{filename_prefix}-sections.csv", canvas_section_rows)
    users_csv_file = make_users_csv("#{filename_prefix}-users.csv", canvas_user_rows)
    enrollments_csv_file = make_enrollments_csv("#{filename_prefix}-enrollments.csv", canvas_enrollment_rows)
    import_proxy = CanvasSisImportProxy.new

    imported_courses_response = import_proxy.import_courses(courses_csv_file)
    raise RuntimeError, 'Course site could not be created!' if imported_courses_response.blank?

    imported_sections_response = import_proxy.import_sections(sections_csv_file)
    if imported_sections_response.blank?
      logger.error("Imported course from #{courses_csv_file} but sections did not import from #{sections_csv_file}")
      return response_hash('WARNING', 'Course site was created without any sections or members!')
    end

    imported_users_response = import_proxy.import_users(users_csv_file)
    if imported_users_response.blank?
      logger.error("Imported course and sections from #{courses_csv_file}, #{sections_csv_file} but users did not import from #{users_csv_file}")
      return response_hash('WARNING', 'Course site was created but members may be missing!')
    end

    imported_enrollments_response = import_proxy.import_enrollments(enrollments_csv_file)
    if imported_enrollments_response.blank?
      logger.error("Imported course, sections, and users from #{courses_csv_file}, #{sections_csv_file}, #{users_csv_file} but memberships did not import from #{enrollments_csv_file}")
      return response_hash('WARNING', 'Course site was created but members may not be enrolled!')
    end

    logger.warn("Successfully imported course from: #{courses_csv_file}, #{sections_csv_file}, #{users_csv_file}, #{enrollments_csv_file}")
    response_hash('Success')
  end

  def subaccount_for_department(department)
    subaccount = "ACCT:#{department}"
    if !CanvasExistenceCheckProxy.new.account_defined?(subaccount)
      # There is no programmatic way to create a subaccount in Canvas.
      logger.error("Cannot provision course site; bCourses account #{subaccount} does not exist!")
      raise RuntimeError, "Could not find bCourses account for department #{department}"
    else
      subaccount
    end
  end

  def response_hash(status, message = '')
    raise ArgumentError, "String type expected" if (status.class != String || message.class != String)
    response = { created_status: status }
    response[:created_message] = message unless message.blank?
    response
  end

  class IdNotUniqueException < Exception
  end

end
