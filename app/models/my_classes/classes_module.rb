module MyClasses::ClassesModule
  extend self

  def initialize(uid)
    @uid = uid
  end

  def current_term
    @current_term ||= Berkeley::Terms.fetch.current
  end

  def grading_in_progress_term
    @grading_in_progress_term ||= Berkeley::Terms.fetch.grading_in_progress
  end

  def course_site_entry(campus_courses, course_site, term)
    return unless matches_term?(course_site, term)
    linked_campus_courses = []
    if (sections = course_site[:sections])
      candidate_ccns = sections.collect {|s| s[:ccn].to_i}
      campus_courses.each do |campus_course|
        if matches_term?(campus_course, term) && campus_course[:sections].find {|s| candidate_ccns.include?(s[:ccn].to_i)}
          linked_campus_courses << {id: campus_course[:listings].first[:id]}
        end
      end
    end
    course_site.slice(:emitter, :id, :name, :shortDescription, :site_url, :term_cd, :term_yr).merge({
      siteType: 'course',
      courses: linked_campus_courses.uniq
    })
  end

  private

  def matches_term?(course, term)
    term && term.year == course[:term_yr].to_i && term.code == course[:term_cd]
  end
end
