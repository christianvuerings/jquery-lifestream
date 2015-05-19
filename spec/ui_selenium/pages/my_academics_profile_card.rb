require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_academics_page'

module CalCentralPages

  class MyAcademicsProfileCard < MyAcademicsPage

    div(:profile_card, :xpath => '//div[@data-ng-if="api.user.profile.hasStudentHistory || api.user.profile.roles.student"]')
    h3(:term_transition_heading, :xpath => '//h3[@data-ng-if="transitionRegStatus && collegeAndLevel.termName"]')
    div(:name, :xpath => '//div/strong[@data-ng-bind="api.user.profile.fullName"]')
    span(:gpa, :xpath => '//span[@data-ng-bind="gpaUnits.cumulativeGpaFloat"]')
    elements(:college, :div, :xpath => '//div[@data-ng-bind="college.college"]')
    elements(:major, :div, :xpath => '//div[@data-ng-bind="college.major"]')
    td(:standing, :xpath => '//strong[@data-ng-bind="collegeAndLevel.standing"]')
    td(:units, :xpath => '//strong[@data-ng-bind="gpaUnits.totalUnits"]')
    span(:level_label, :xpath => '//th[text()="Level"]/following-sibling::th/span')
    td(:level, :xpath => '//strong[@data-ng-bind="collegeAndLevel.level"]')
    td(:level_non_ap, :xpath => '//strong[@data-ng-bind="collegeAndLevel.nonApLevel"]')
    td(:uid , :xpath => '//strong[@data-ng-bind="api.user.profile.uid"]')
    td(:sid , :xpath => '//strong[@data-ng-bind="api.user.profile.sid"]')
    div(:non_reg_student_msg, :xpath => '//div[contains(text(), "You are not currently registered as a student.")]')
    div(:ex_student_msg, :xpath => '//div[contains(text(),"You are not currently considered an active student.")]')
    div(:new_student_msg, :xpath => '//div[contains(text(),"You are registered as a student but not currently considered active by all campus services.")]')
    div(:concur_student_msg, :xpath => '//div[contains(text(),"You are a concurrent enrollment student.")]')
    link(:uc_ext_link, :xpath => '//a[contains(text(),"UC Berkeley Extension")]')
    link(:eap_link, :xpath => '//a[contains(text(),"Berkeley International Office")]')

    def all_colleges
      colleges = []
      college_elements.each { |college| colleges.push(college.text) }
      colleges
    end

    def all_majors
      majors = []
      major_elements.each { |major| majors.push(major.text) }
      majors
    end

  end
end
