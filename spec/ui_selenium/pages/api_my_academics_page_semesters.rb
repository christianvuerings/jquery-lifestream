require 'selenium-webdriver'
require 'page-object'
require_relative 'api_my_academics_page'

class ApiMyAcademicsPageSemesters < ApiMyAcademicsPage

  include PageObject

  # SEMESTERS

  def all_student_semesters
    @parsed['semesters']
  end

  def all_teaching_semesters
    @parsed['teachingSemesters']
  end

  def semesters_in_time_bucket(semesters, time_bucket)
    semesters.select { |semester| semester['timeBucket'] == time_bucket }
  end

  def past_semesters(semesters)
    semesters_in_time_bucket(semesters, 'past')
  end

  def current_semester(semesters)
    semesters.nil? ? nil : semesters_in_time_bucket(semesters, 'current')[0]
  end

  def future_semesters(semesters)
    semesters_in_time_bucket(semesters, 'future')
  end

  # The semesters visible by default on the My Academics page
  def default_semesters_in_ui(semesters)
    default_semesters = future_semesters(semesters)
    default_semesters << current_semester(semesters) unless current_semester(semesters).nil?
    default_semesters << past_semesters(semesters)[0] if past_semesters(semesters).any?
    default_semesters
  end

  def semester_name(semester)
    semester['name']
  end

  def semester_names(semesters)
    names = []
    semesters.each { |semester| names << semester_name(semester) }
    names
  end

  def semester_slug(semester)
    semester['slug']
  end

  def has_enrollment_data?(semester)
    semester['hasEnrollmentData']
  end

  # COURSES

  def semester_courses(semester)
    semester['classes']
  end

  # Semester cards list courses once per primary section OR once per transcript record (if transcripts exist)
  def semester_card_courses(semester, courses)
    if has_enrollment_data?(semester)
      course_list = []
      courses.each do |course|
        if course_transcripts(course).nil?
          course_primary_sections(course).each { course_list << course }
        else
          course_transcripts(course).each { course_list << course }
        end
      end
      course_list
    else
      courses
    end
  end

  # Semester pages always list courses once per primary section
  def courses_by_primary_section(courses)
    course_list = []
    courses.each do |course|
      course_primary_sections(course).each { course_list << course }
    end
    course_list
  end

  def course_code(course)
    course['course_code']
  end

  def course_codes(courses)
    codes = []
    courses.each { |course| codes << course_code(course) }
    codes
  end

  # Semester cards show course codes differently depending on enrollment data, primary sections, and transcript data
  def semester_card_course_codes(semesters, semester)
    codes = []
    courses = semester_courses(semester)
    courses.each do |course|
      if has_enrollment_data?(semester)
        if past_semesters(semesters).include?(semester)
          if course_transcripts(course).nil?
            course_primary_sections(course).each { codes << course_code(course) }
          else
            course_transcripts(course).each { codes << course_code(course) }
          end
        elsif !past_semesters(semesters).include?(semester) && multiple_primaries?(course)
          course_primary_sections(course).each { |section| codes << "#{course_code(course)} #{section_label(section)}" }
        else
          codes << course_code(course)
        end
      else
        codes << course_code(course)
      end
    end
    codes
  end

  def course_title(course)
    (course['title'].gsub('  ', ' ')).strip
  end

  def course_titles(courses)
    titles = []
    courses.each { |course| titles << course_title(course) }
    titles
  end

  def course_url(course)
    course['url']
  end

  def course_transcripts(course)
    course['transcript']
  end

  def grade_options(courses)
    options = []
    courses.each { |course| options.concat(sections_grade_options(course_sections(course))) }
    options.compact
  end

  def multiple_primaries?(course)
    course['multiplePrimaries']
  end

  # Enrollment records associate units with primary sections
  def units_by_enrollment(courses)
    units = []
    courses.each do |course|
      course_primary_sections(course).each { |section| units << section['units'] }
    end
    units
  end

  # Transcripts do not necessarily associate units with primary sections
  def units_by_transcript(courses)
    units = []
    courses.each do |course|
      if course_transcripts(course).nil?
        course_primary_sections(course).each { |section| units << section['units'] }
      else
        course_transcripts(course).each { |transcript| units << transcript['units'] }
      end
    end
    units
  end

  def transcript_grade(transcript)
    transcript['grade']
  end

  def course_grades(course)
    grades = []
    course_transcripts(course).each { |transcript| grades << transcript_grade(transcript) }
    grades
  end

  def semester_grades(semesters, courses, semester)
    grades = []
    courses.each do |course|
      if past_semesters(semesters).include?(semester)
        if course_transcripts(course).nil?
          course_primary_sections(course).each { | | grades << '--' }
        else
          course_transcripts(course).each do |transcript|
            if transcript_grade(transcript).nil?
              grades << ''
            else
              grades << transcript_grade(transcript)
            end
          end
        end
        # EAP grades can turn up on semester cards during the current semester
      elsif !has_enrollment_data?(semester) && !course_transcripts(course).nil?
        course_transcripts(course).each { |transcript| grades << transcript_grade(transcript) }
      end
    end
    grades
  end

  def course_listing_course_codes(course)
    codes = []
    course['listings'].each { |listing| codes << listing['course_code'] }
    codes
  end

  def semester_listing_course_codes(semester)
    codes = []
    semester_courses(semester).each { |course| codes.concat(course_listing_course_codes(course)) }
    codes
  end

  # SECTIONS

  def course_sections(course)
    course['sections']
  end

  def primary_section?(section)
    section['is_primary_section']
  end

  def course_primary_sections(course)
    prim_sections = []
    course_sections(course).each { |section| prim_sections << section if primary_section? section }
    prim_sections
  end

  # Courses with multiple primary sections can have secondaries associated with only one of the primaries
  def associated_sections(course, primary_section)
    assoc_sections = []
    assoc_sections << primary_section
    course_sections(course).each { |section| assoc_sections << section if section['associatedWithPrimary'] == section_slug(primary_section) }
    assoc_sections
  end

  def sections_by_listing(course)
    sections = []
    course_sections(course).each { |section| sections << section if section_course_code(section) == course_code(course) }
    sections
  end

  def sections_ccns(sections)
    ccns = []
    sections.each { |section| ccns << section['ccn'] }
    ccns
  end

  def section_course_code(section)
    section['courseCode']
  end

  def sections_units(sections)
    units = []
    sections.each { |section| units << section['units'] }
    units.compact
  end

  def section_label(section)
    section['section_label']
  end

  def sections_labels(sections)
    labels = []
    sections.each { |section| labels << section_label(section) }
    labels
  end

  # Section labels are omitted from class page section schedules if the section has no schedule
  def section_schedule_labels(sections)
    labels = []
    sections.each { |section| labels << section_label(section) unless section_schedules(section).empty? }
    labels
  end

  def courses_section_labels(courses)
    labels = []
    courses.each { |course| labels.concat(sections_labels(course_sections(course))) }
    labels
  end

  def section_schedules(section)
    section['schedules']
  end

  def section_buildings(section)
    buildings = []
    section_schedules(section).each { |schedule| buildings << schedule['buildingName'] }
    buildings
  end

  def section_rooms(section)
    rooms = []
    section_schedules(section).each { |schedule| rooms << schedule['roomNumber'] }
    rooms
  end

  def section_times(section)
    times = []
    section_schedules(section).each { |schedule| times << schedule['schedule'] }
    times
  end

  def sections_schedules(sections)
    schedules = []
    sections.each do |section|
      section_schedules(section).each do |schedule|
        index = section_schedules(section).index(schedule)
        section_schedule = String.new
        unless section_times(section)[index].nil? || section_times(section)[index].blank?
          section_schedule.concat("#{section_times(section)[index]} ")
        end
        unless section_times(section)[index].nil? && section_buildings(section)[index].nil?
          section_schedule.concat('| ')
        end
        unless section_rooms(section)[index].nil?
          section_schedule.concat("#{section_rooms(section)[index].strip} ")
        end
        unless section_buildings(section)[index].nil?
          section_schedule.concat("#{section_buildings(section)[index].strip}")
        end
        schedules << section_schedule
      end
    end
    schedules
  end

  def section_instructor_names(section)
    names = []
    section['instructors'].each { |instructor| names << instructor['name'] }
    names
  end

  def sections_instructor_names(sections)
    names = []
    sections.each { |section| names.concat(section_instructor_names(section)) }
    names
  end

  def sections_grade_options(sections)
    options = []
    sections.each { |section| options << section['gradeOption'] }
    options.compact
  end

  def section_slug(section)
    section['slug']
  end

  def section_url(section)
    section['url']
  end

# WAIT LISTS

  def wait_list_courses(courses)
    wait_lists = []
    courses.each { |course| wait_lists << course unless wait_list_course_sections(course).empty? }
    wait_lists
  end

  def wait_list_course_sections(course)
    wait_list_sections = []
    course_sections(course).each { |section| wait_list_sections << section unless wait_list_position(section).nil? }
    wait_list_sections
  end

  def wait_list_semester_sections(courses)
    wait_list_sections = []
    courses.each { |course| wait_list_sections.concat(wait_list_course_sections(course)) }
    wait_list_sections
  end

  def wait_list_primary_sections(courses)
    wait_list_semester_sections(courses).delete_if { |section| !primary_section?(section) }
  end

  def wait_list_course_codes(wait_list_courses)
    codes = []
    wait_list_courses.each do |course|
      wait_list_course_sections(course).each { codes << course_code(course) }
    end
    codes
  end

  def wait_list_course_titles(wait_list_courses)
    titles = []
    wait_list_courses.each do |course|
      wait_list_course_sections(course).each { titles << course_title(course) }
    end
    titles
  end

  def wait_list_position(section)
    section['waitlistPosition']
  end

  def wait_list_positions(sections)
    positions = []
    sections.each { |section| positions << wait_list_position(section).to_s }
    positions
  end

  def enrollment_limits(wait_list_courses)
    limits = []
    wait_list_courses.each do |course|
      course_sections(course).each { |section| limits << section['enroll_limit'].to_s }
    end
    limits
  end

  # ADDITIONAL CREDITS (e.g., AP course work)

  def addl_credits
    @parsed['additionalCredits']
  end

  def addl_credits_titles
    titles = []
    addl_credits.each { |credit| titles << credit['title'] }
    titles
  end

  def addl_credits_units
    units = []
    addl_credits.each { |credit| units << credit['units'] }
    units
  end

  # COURSE SITES

  def course_sites(course)
    course['class_sites']
  end

  def course_site_name(course_site)
    course_site['name']
  end

  def course_site_names(course)
    names = []
    unless course_sites(course).nil?
      course_sites(course).each { |site| names << course_site_name(site) }
    end
    names
  end

  def semester_course_site_names(semester_courses)
    names = []
    semester_courses.each { |course| names.concat(course_site_names(course)) }
    names
  end

  def course_site_descrip(course_site)
    course_site['shortDescription']
  end

  def course_site_descrips(course)
    descriptions = []
    unless course_sites(course).nil?
      course_sites(course).each do |site|
        unless course_site_descrip(site).nil? || course_site_descrip(site) == course_site_name(site) || course_site_descrip(site) == course_title(course)
          descriptions << course_site_descrip(site)
        end
      end
    end
    descriptions
  end

  def semester_course_site_descrips(semester_courses)
    descriptions = []
    semester_courses.each { |course| descriptions.concat(course_site_descrips(course)) }
    descriptions
  end

end
