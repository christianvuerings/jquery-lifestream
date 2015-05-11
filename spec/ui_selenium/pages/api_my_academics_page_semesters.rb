require 'selenium-webdriver'
require 'page-object'
require_relative 'api_my_academics_page'

class ApiMyAcademicsPageSemesters < ApiMyAcademicsPage

  include PageObject

  # SEMESTERS

  def all_semesters
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
    semesters_in_time_bucket(semesters, 'current')[0]
  end

  def future_semesters(semesters)
    semesters_in_time_bucket(semesters, 'future')
  end

  # The semesters visible by default on the My Academics page
  def default_semesters_in_ui(semesters)
    default_semesters = []
    default_semesters.concat future_semesters(semesters)
    unless current_semester(semesters).nil?
      default_semesters.push current_semester(semesters)
    end
    if past_semesters(semesters).any?
      default_semesters.push(past_semesters(semesters)[0])
    end
    default_semesters
  end

  def semester_name(semester)
    semester['name']
  end

  def semester_names(semesters)
    names = []
    semesters.each { |semester| names.push(semester_name(semester)) }
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
          primary_sections(course).each { course_list.push(course) }
        else
          course_transcripts(course).each { course_list.push(course) }
        end
      end
      course_list
    else
      courses
    end
  end

  # Semester pages always list courses once per primary section
  def semester_page_courses(courses)
    course_list = []
    courses.each do |course|
      primary_sections(course).each { course_list.push(course) }
    end
    course_list
  end

  def course_code(course)
    course['course_code']
  end

  def course_codes(courses)
    codes = []
    courses.each { |course| codes.push(course_code(course)) }
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
            primary_sections(course).each { codes.push(course_code(course)) }
          else
            course_transcripts(course).each { codes.push(course_code(course)) }
          end
        elsif !past_semesters(semesters).include?(semester) && multiple_primaries?(course)
          primary_sections(course).each { |section| codes.push("#{course_code(course)} #{section_label(section)}") }
        else
          codes.push(course_code(course))
        end
      else
        codes.push(course_code(course))
      end
    end
    codes
  end

  def course_title(course)
    (course['title'].gsub('  ', ' ')).strip
  end

  def course_titles(courses)
    titles = []
    courses.each { |course| titles.push(course_title(course)) }
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
    courses.each { |course| options.concat(section_grade_options(sections(course))) }
    options.compact
  end

  def multiple_primaries?(course)
    course['multiplePrimaries']
  end

  # Enrollment records associate units with primary sections
  def units_by_enrollment(courses)
    units = []
    courses.each do |course|
      primary_sections(course).each { |section| units.push(section['units']) }
    end
    units
  end

  # Transcripts do not necessarily associate units with primary sections
  def units_by_transcript(courses)
    units = []
    courses.each do |course|
      if course_transcripts(course).nil?
        primary_sections(course).each { |section| units.push(section['units']) }
      else
        course_transcripts(course).each { |transcript| units.push(transcript['units']) }
      end
    end
    units
  end

  def transcript_grade(transcript)
    transcript['grade']
  end

  def course_grades(course)
    grades = []
    course_transcripts(course).each do |transcript|
      grades.push(transcript_grade(transcript))
    end
    grades
  end

  def semester_grades(semesters, courses, semester)
    grades = []
    courses.each do |course|
      if past_semesters(semesters).include?(semester)
        if course_transcripts(course).nil?
          primary_sections(course).each { | | grades.push('--') }
        else
          course_transcripts(course).each do |transcript|
            if transcript_grade(transcript).nil?
              grades.push('')
            else
              grades.push(transcript_grade(transcript))
            end
          end
        end
        # EAP grades can turn up on semester cards during the current semester
      elsif !has_enrollment_data?(semester) && !course_transcripts(course).nil?
        course_transcripts(course).each { |transcript| grades.push(transcript_grade(transcript)) }
      end
    end
    grades
  end

  def course_listing_course_codes(course)
    codes = []
    course['listings'].each { |listing| codes.push(listing['course_code']) }
    codes
  end

  def semester_listing_course_codes(semester)
    codes = []
    semester_courses(semester).each { |course| codes.concat(course_listing_course_codes(course)) }
    codes
  end

  # SECTIONS

  def sections(course)
    course['sections']
  end

  def primary_sections(course)
    prim_sections = []
    sections(course).each do |section|
      if section['is_primary_section']
        prim_sections.push(section)
      end
    end
    prim_sections
  end

  # Courses with multiple primary sections can have secondaries associated with only one of the primaries
  def associated_sections(course, primary_section)
    assoc_sections = []
    assoc_sections.push(primary_section)
    primary_slug = section_slug(primary_section)
    sections(course).each do |section|
      if section['associatedWithPrimary'] == primary_slug
        assoc_sections.push(section)
      end
    end
    assoc_sections
  end

  def sections_by_listing(course)
    sections = []
    sections(course).each do |section|
      if section_course_code(section) == course_code(course)
        sections.push(section)
      end
    end
    sections
  end

  def section_ccns(sections)
    ccns = []
    sections.each { |section| ccns.push(section['ccn']) }
    ccns
  end

  def section_course_code(section)
    section['courseCode']
  end

  def section_units(sections)
    units = []
    sections.each { |section| units.push(section['units']) }
    units.compact
  end

  def section_label(section)
    section['section_label']
  end

  def section_labels(sections)
    labels = []
    sections.each { |section| labels.push(section_label(section)) }
    labels
  end

  # Section labels are omitted from class page section schedules if the section has no schedule
  def section_schedule_labels(sections)
    labels = []
    sections.each do |section|
      unless section_schedules(section).empty?
        labels.push(section_label(section))
      end
    end
    labels
  end

  def all_section_labels(courses)
    labels = []
    courses.each { |course| labels.concat(section_labels(sections(course))) }
    labels
  end

  def section_instruction_formats(course)
    formats = []
    sections(course).each { |section| formats.push(section['instruction_format']) }
    formats
  end

  def section_schedules(section)
    section['schedules']
  end

  def section_buildings(section)
    buildings = []
    section_schedules(section).each { |schedule| buildings.push(schedule['buildingName']) }
    buildings
  end

  def section_rooms(section)
    rooms = []
    section_schedules(section).each { |schedule| rooms.push(schedule['roomNumber']) }
    rooms
  end

  def section_times(section)
    times = []
    section_schedules(section).each { |schedule| times.push(schedule['schedule']) }
    times
  end

  def course_section_schedules(sections)
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
        schedules.push(section_schedule)
      end
    end
    schedules
  end

  def section_instructor_names(section)
    names = []
    section['instructors'].each { |instructor| names.push(instructor['name']) }
    names
  end

  def course_instructor_names(sections)
    names = []
    sections.each { |section| names.concat(section_instructor_names(section)) }
    names
  end

  def section_grade_options(sections)
    options = []
    sections.each { |section| options.push(section['gradeOption']) }
    options.compact
  end

  def section_slug(section)
    section['slug']
  end

  def section_url(section)
    section['url']
  end

# WAIT LISTS

  def wait_list_courses(semester_courses)
    wait_lists = []
    semester_courses.each do |course|
      unless wait_list_sections(course).empty?
        wait_lists.push(course)
      end
    end
    wait_lists
  end

  def wait_list_sections(course)
    wait_list_sections = []
    sections(course).each do |section|
      unless wait_list_position(section).nil?
        wait_list_sections.push(section)
      end
    end
    wait_list_sections
  end

  def wait_list_course_codes(wait_list_courses)
    codes = []
    wait_list_courses.each do |course|
      wait_list_sections(course).each { codes.push(course_code(course)) }
    end
    codes
  end

  def wait_list_course_titles(wait_list_courses)
    titles = []
    wait_list_courses.each do |course|
      wait_list_sections(course).each { titles.push(course_title(course)) }
    end
    titles
  end

  def wait_list_position(section)
    section['waitlistPosition']
  end

  def wait_list_positions(wait_list_courses)
    positions = []
    wait_list_courses.each do |course|
      sections(course).each { |section| positions.push(wait_list_position(section).to_s) }
    end
    positions
  end

  def enrollment_limits(wait_list_courses)
    limits = []
    wait_list_courses.each do |course|
      sections(course).each { |section| limits.push(section['enroll_limit'].to_s) }
    end
    limits
  end

  # ADDITIONAL CREDITS (e.g., AP course work)

  def addl_credits
    @parsed['additionalCredits']
  end

  def addl_credits_titles
    titles = []
    addl_credits.each { |credit| titles.push(credit['title']) }
    titles
  end

  def addl_credits_units
    units = []
    addl_credits.each { |credit| units.push(credit['units']) }
    units
  end

end
