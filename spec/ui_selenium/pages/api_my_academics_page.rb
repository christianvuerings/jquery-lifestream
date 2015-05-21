require 'selenium-webdriver'
require 'page-object'
require_relative '../util/web_driver_utils'

class ApiMyAcademicsPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info('Parsing JSON from /api/my/academics')
    driver.get(WebDriverUtils.base_url + '/api/my/academics')
    wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.academics_timeout)
    wait.until { driver.find_element(:xpath => '//pre[contains(.,"MyAcademics::Merged")]') }
    body = driver.find_element(:xpath, '//pre').text
    @parsed = JSON.parse(body)
  end

  def academics_date(epoch)
    (Time.strptime(epoch, '%s')).strftime("%a %b %-d")
  end

  def academics_time(epoch)
    time_format = (Time.strptime(epoch, '%s')).strftime("%-l:%M %p")
    if time_format == '12:00 PM'
      time = 'Noon'
    else
      time = time_format
    end
    time
  end

  # PROFILE

  def college_and_level
    @parsed['collegeAndLevel']
  end

  def standing
    college_and_level['standing']
  end

  def has_no_standing?
    college_and_level['empty']
  end

  def level
    college_and_level['level']
  end

  def non_ap_level
    college_and_level['nonApLevel']
  end

  def gpa_units
    @parsed['gpaUnits']
  end

  def gpa
    gpa_units['cumulativeGpa']
  end

  def ttl_units
    units = gpa_units['totalUnits']
    if units.nil?
      nil
    else
      (units == units.floor) ? units.floor : units
    end
  end

  def units_attempted
    gpa_units['totalUnitsAttempted']
  end

  def colleges_and_majors
    college_and_level['colleges']
  end

  def colleges
    colleges = []
    colleges_and_majors.each do |college|
      # For double majors within the same college, only show the college once
      unless college['college'] == ''
        colleges.push(college['college'])
      end
    end
    colleges
  end

  def majors
    majors = []
    colleges_and_majors.each { |major| majors.push(major['major']) }
    majors
  end

  def term_name
    college_and_level['termName']
  end

  def term_transition?
    (@parsed['transitionRegStatus'].present?) ? true : false
  end

  # UNDERGRAD REQUIREMENTS

  def requirements
    @parsed['requirements'].inject({}) { |map, reqt| map[reqt['name']] = reqt; map }
  end

  def writing_reqt_met?
    reqt = requirements['UC Entry Level Writing']
    if reqt['status'] == 'met'
      true
    else
      false
    end
  end

  def history_reqt_met?
    reqt = requirements['American History']
    if reqt['status'] == 'met'
      true
    else
      false
    end
  end

  def institutions_reqt_met?
    reqt = requirements['American Institutions']
    if reqt['status'] == 'met'
      true
    else
      false
    end
  end

  def cultures_reqt_met?
    reqt = requirements['American Cultures']
    if reqt['status'] == 'met'
      true
    else
      false
    end
  end


  # BLOCKS

  def active_blocks
    @parsed['regblocks']['activeBlocks']
  end

  def inactive_blocks
    @parsed['regblocks']['inactiveBlocks']
  end

  def block_type(item)
    item['type']
  end

  def block_reason(item)
    item['reason']
  end

  def block_office(item)
    item['office']
  end

  def block_date(item)
    item['blockedDate']['dateString']
  end

  def block_message(item)
    item['message']
  end

  def block_cleared_date(item)
    item['clearedDate']['dateString']
  end

  def active_block_types
    types = []
    active_blocks.select do |item|
      type = block_type(item)
      types.push(type)
    end
    types
  end

  def active_block_reasons
    reasons = []
    active_blocks.select do |item|
      reason = block_reason(item)
      reasons.push(reason)
    end
    reasons
  end

  def active_block_offices
    offices = []
    active_blocks.select do |item|
      office = block_office(item)
      offices.push(office)
    end
    offices
  end

  def active_block_dates
    dates = []
    active_blocks.select do |item|
      date = (Time.strptime(block_date(item), '%m/%d/%Y')).strftime('%m/%d/%y')
      dates.push(date)
    end
    dates
  end

  def inactive_block_types
    types = []
    inactive_blocks.select do |item|
      type = block_type(item)
      types.push(type)
    end
    types
  end

  def inactive_block_dates
    dates = []
    inactive_blocks.select do |item|
      date = (Time.strptime(block_date(item), '%m/%d/%Y')).strftime('%m/%d/%y')
      dates.push(date)
    end
    dates
  end

  def inactive_block_cleared_dates
    dates = []
    inactive_blocks.select do |item|
      date = (Time.strptime(block_cleared_date(item), '%m/%d/%Y')).strftime('%m/%d/%y')
      dates.push(date)
    end
    dates
  end

  # FINAL EXAMS

  def exam_schedules
    @parsed['examSchedule']
  end

  def has_exam_schedules
    if exam_schedules.nil? || exam_schedules.length == 0
      false
    elsif exam_schedules.length > 0
      true
    end
  end

  def exam_epochs
    epochs = []
    exam_schedules.each { |schedule| epochs.push(schedule['date']['epoch'].to_s) }
    epochs
  end

  def all_exam_dates
    dates = []
    exam_epochs.each { |epoch| dates.push(academics_date(epoch)) }
    dates
  end

  def all_exam_times
    times = []
    exam_schedules.each { |exam| times.push(exam['time']) }
    times
  end

  def all_exam_courses
    courses = []
    exam_schedules.each { |schedule| courses.push(schedule['course_code']) }
    courses
  end

  def exam_locations(exam)
    locations = exam['locations']
    raw_locations = []
    locations.each { |location| raw_locations.push(location['raw'].gsub("  ", " ").strip) }
    raw_locations
  end

  def all_exam_locations
    all_locations = []
    exam_schedules.each { |exam| all_locations.concat(exam_locations(exam)) }
    all_locations.sort
  end

  # TELE-BEARS

  def tele_bears
    @parsed['telebears']
  end

  def has_tele_bears
    begin
      tele_bears.length > 0
      true
    rescue
      false
    end
  end

  def tele_bears_phases(semesters)
    all_phases = []
    semesters.each { |semester| all_phases.concat(semester['phases']) }
    all_phases
  end

  def tele_bears_term_year(semester)
    semester['term'] + ' ' + semester['year'].to_s
  end

  def tele_bears_term_years(semesters)
    term_years = []
    semesters.each { |semester| term_years.concat(semester['term'] + ' ' + semester['year'].to_s) }
    term_years
  end

  def tele_bears_semester_slug(semester)
    semester['slug']
  end

  def tele_bears_advisor_code_req?(semester)
    semester['advisorCodeRequired']['required']
  end

  def tele_bears_advisor_codes(semesters)
    code_reqts = []
    semesters.each { |semester| code_reqts.push(tele_bears_advisor_code_req?(semester)) }
    code_reqts
  end

  def tele_bears_advisor_code_msgs(semesters)
    code_msgs = []
    semesters.each do |semester|
      if tele_bears_advisor_code_req?(semester)
        # Deliberately ignore calso and revoked messages, which will therefore trigger a test failure if either turns up in test data.
        # These messages rarely appear, so QA would like to hear about them when they do.
        code_msgs.push('Before your Tele-BEARS appointment you need to get a code from your advisor.')
      else
        code_msgs.push('You do not need an advisor code for this semester.')
      end
    end
    code_msgs
  end

  def tele_bears_phase_starts(semesters)
    epochs = []
    tele_bears_phases(semesters).each { |item| epochs.push(item['startTime']['epoch'].to_s) }
    phase_starts = []
    epochs.each { |epoch| phase_starts.push(tele_bears_date_time(epoch)) }
    phase_starts
  end

  def tele_bears_phase_endings(semesters)
    epochs = []
    tele_bears_phases(semesters).each { |item| epochs.push(item['endTime']['epoch'].to_s) }
    phase_ends = []
    epochs.each { |item| phase_ends.push(tele_bears_date_time(item)) }
    phase_ends
  end

  def tele_bears_date_time(epoch)
    academics_date(epoch) + ' | ' + academics_time(epoch)
  end
end
