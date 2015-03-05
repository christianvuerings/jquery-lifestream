require 'selenium-webdriver'
require 'page-object'
require_relative 'api_my_academics_page'
require_relative '../util/web_driver_utils'

class ApiMyAcademicsPageSemesters < ApiMyAcademicsPage

  include PageObject
  include ClassLogger

  # SEMESTERS

  def all_semesters
    @parsed['semesters']
  end

  def semesters_in_time_bucket(time_bucket)
    all_semesters.select { |semester| semester['timeBucket'] == time_bucket }
  end

  def past_semesters
    semesters_in_time_bucket('past')
  end

  def current_semester
    semesters_in_time_bucket('current')
  end

  def future_semesters
    semesters_in_time_bucket('future')
  end

  def default_semesters_in_ui
    default_semesters = future_semesters + current_semester
    unless past_semesters.length == 0
      default_semesters.push(past_semesters[0])
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

  # COURSES

  def semester_courses(semester)
    semester['classes']
  end

  def course_code(course)
    course['course_code']
  end

  def course_codes(courses)
    codes = []
    courses.each { |course| codes.push(course_code(course)) }
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

  def course_transcript(course)
    course['transcript']
  end

  def course_grade_options(courses)
    options = []
    courses.each { |course| options.concat(section_grade_options(course)) }
    options
  end

  # Semester pages list enrolled courses once per primary section
  def courses_per_prim_section(semester_courses)
    courses = []
    semester_courses.each do |course|
      primary_sections(course).each { courses.push(course) }
    end
    courses
  end

  # Semester cards list courses once per transcript record (if record exists), otherwise once per primary section
  def courses_per_transcript(semester_courses)
    courses = []
    semester_courses.each do |course|
      if course_transcript(course).nil?
        primary_sections(course).each { courses.push(course) }
      else
        course_transcript(course).each { courses.push(course) }
      end
    end
    courses
  end

  def units_per_prim_section(courses)
    units = []
    courses.each do |course|
      primary_sections(course).each { |section| units.push(section['units']) }
    end
    units
  end

  def units_per_transcript(courses)
    units = []
    courses.each do |course|
      if course_transcript(course).nil?
        primary_sections(course).each { |section| units.push(section['units']) }
      else
        course_transcript(course).each { |transcript| units.push(transcript['units']) }
      end
    end
    units
  end

  def grades(courses, semester)
    grades = []
    courses.each do |course|
      if past_semesters.include?(semester)
        if course_transcript(course).nil?
          primary_sections(course).each { | | grades.push('--') }
        else
          course_transcript(course).each do |transcript|
            if transcript['grade'].nil?
              grades.push('')
            else
              grades.push(transcript['grade'])
            end
          end
        end
      end
    end
    grades
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

  def section_ccns(course)
    ccns = []
    sections(course).each { |section| ccns.push(section['ccn']) }
    ccns
  end

  def section_units(course)
    units = []
    primary_sections(course).each { |section| units.push(section['units']) }
    units
  end

  def section_labels(course)
    labels = []
    sections(course).each { |section| labels.push(section['section_label']) }
    labels
  end

  def all_section_labels(courses)
    labels = []
    courses.each { |course| labels.concat(section_labels(course)) }
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

  def course_section_schedules(course)
    schedules = []
    sections(course).each do |section|
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

  def course_instructor_names(course)
    names = []
    sections(course).each { |section| names.push(section_instructor_names(section)) }
    names
  end

  def section_grade_options(course)
    options = []
    primary_sections(course).each { |section| options.push(section['gradeOption']) }
    options
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

end
