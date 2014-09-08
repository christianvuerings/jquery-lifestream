module Notifications
  class RegBlockCodeTranslator
    def translate_bearfacts_proxy(reason_code, office)
      office_code = office.strip
      Rails.cache.fetch("global/BearfactsRegBlock/reason_code/#{reason_code}_#{office_code}", :expires_in => 0) {
        {
          message: self.class.translate_to_message(reason_code, office_code),
          office: self.class.translate_office_code(office_code),
        }.merge(self.class.translate_to_type_and_reason(reason_code))
      }
    end

    private

    def self.init_message_translation_hash
      lf_text = <<-EOS
      <p>Your registration as an official Berkeley student is blocked by the Library due to
      outstanding bills of $200 or more.  Until this block is cleared, you cannot register for classes,
      use certain campus services (e.g. libraries, health services, recreational sports facilities,
      Class Pass bus travel, Career Center), or obtain official campus transcripts.</p>
      <p>To clear this block you must pay the balance:</p>
      <ul>
      <li>via credit card ONLINE through your personal
      <a href="http://oskicat.berkeley.edu/screens/ssoauth.html?service=https%3a%2f%2foskicat.berkeley.edu%3a443%2f">
      MyOskiCat account</a>; or</li>
      <li>In person at the Privileges Desk (198 Doe) during our
      <a href="http://www.lib.berkeley.edu/hours/?day=&libraries%5Bid%5D%5B%5D=177&commit=Show+hours">normal business hours</a>.
      Payments are accepted via credit/debit card or personal check.</li>
      </ul>
      EOS

      ll_text = <<-EOS
      <p>Your registration as an official Berkeley student is blocked by Billing and Payment Services due to an unpaid Perkins,
      HPSL or Institutional loan. Until this block is cleared, you <strong>cannot</strong> register for classes, use certain campus services
      (e.g. libraries, health services, recreational sports facilities, Class Pass bus travel, Career Center), or obtain official
      campus transcripts.</p>
      <p>To clear this block, log into ACS and make an online payment at <a href="http://www.acs-education.com/">www.acs-education.com</a>.
      If you have questions, contact an account consultant at (510) 642-7001.</p>
      EOS

      cars_text = <<-EOS
      <p>A block has been placed on your record due to a past due CARS account balance. Blocks are placed on accounts that are
      more than 60 days past due and owing more than $100. While the block will not prevent you from enrolling in classes through
      Tele-BEARS, it will prevent grades from posting to your transcript and prevent official registration for upcoming semesters.
      A hold is placed on your transcript and diploma.</p>
      <p>To clear this block, please submit a payment. For a complete listing of CARS payment options visit
      <a href="http://studentcentral.berkeley.edu/payments">studentcentral.berkeley.edu/payments</a>. If you have questions, visit
      Cal Student Central at <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?sproulhall">120 Sproul Hall</a> or call
      (510) 664-9181.</p>
      EOS

      housing_text = <<-EOS
      <p>Your registration as an official Berkeley student is blocked by the Housing Office due to an unpaid childcare bill. Until
      this block is cleared, you <strong>cannot</strong> register for classes, use certain campus services (e.g. libraries, health services,
      recreational sports facilities, Class Pass bus travel, Career Center), or obtain official campus transcripts.</p>
      <p>To clear this block, please pay your bill at the RSSP Cashier's Office at 2610 Channing Way, Berkeley, CA 94720.
      Only cash, cashier checks or money order will be accepted. If you have questions, contact Marina Moreida at (510) 643-1482.</p>
      EOS

      admissions_ugrad = <<-EOS
      <p>Your registration as an official Berkeley student is blocked by the Office of Undergraduate Admissions for failure to
      meet your Conditions of Admission. Though you may enroll in classes for the current term, until this block is
      cleared you <strong>cannot</strong> enroll in classes for the next term, use campus services (e.g. libraries, health services,
      recreational sports facilities, Class Pass bus travel, Career Center, etc.), receive final grades, or obtain official
      campus transcripts.</p>
      <p>To clear this block, follow these procedures:</p>
      <ul>
      <li>Freshmen: Call (510) 642-3175 or email us at <a href="mailto:freshmanadmit@berkeley.edu">freshmanadmit@berkeley.edu</a>.</li>
      <li>Transfers: Contact your assigned Admissions Officer as listed at the bottom of your Conditions of Admission.</li>
      </ul>
      <p>The Office of Undergraduate Admissions is located at 110 Sproul Hall.</p>
      EOS

      admissions_grad = <<-EOS
      <p>Your registration as an official Berkeley student is blocked by the Graduate Admissions Office because you have not
      submitted one or more required documents.</p>
      <p>To clear this block, please contact Graduate Admissions at (510) 642-7405 or <a href="mailto:gradadm@berkeley.edu">
      gradadm@berkeley.edu</a>.</p>
      EOS

      status_lapse = <<-EOS
      <p>Your registration as an official Berkeley student is blocked by the Office of the Registrar for failure to pay the
      balance of your registration fees from a previous term. Though you may enroll in classes for the current term,
      until this block is cleared you <strong>cannot</strong> enroll in classes for the next term, use campus services (e.g. libraries,
      health services, recreational sports facilities, Class Pass bus travel, Career Center, etc.), receive final grades, or
      obtain official campus transcripts.</p>
      <p>To clear this block, you must pay the balance on your CARS account and wait two weeks after your payment has cleared.
      If you have questions about this block, please contact <a href="http://studentcentral.berkeley.edu/">Cal Student Central</a>
      at 120 Sproul Hall or call (510) 664-9181.</p>
      EOS

      education_abroad = <<-EOS
      <p>Your registration as an official Berkeley student is blocked by the Office of the Registrar at the request of the main
      office of the Education Abroad Program (EAP) at UC Santa Barbara. Though you may enroll in classes for the current term
      term, until this block is cleared you <strong>cannot</strong> enroll in classes for the next term, use campus services (e.g. libraries,
      health services, recreational sports facilities, Class Pass bus travel, Career Center, etc.), receive final grades,
      or obtain official campus transcripts.</p>
      <p>To clear this block, contact <a href="http://studentcentral.berkeley.edu/">Cal Student Central</a> at 120 Sproul Hall,
      or call (510) 664-9181. You may also call the EAP main office at UC Santa Barbara at (805) 893-4812.</p>
      EOS

      misconduct = <<-EOS
      <p>Your registration as an official UC Berkeley student has been blocked by the Center for Student Conduct due to overdue
      sanction(s) resulting from your student conduct case(s). Your block will be lifted once the Center for Student Conduct
      receives confirmation that you have completed your overdue sanction(s). Though you may enroll in classes for the {current
      term} term, until this block is cleared you <strong>cannot</strong> enroll in classes for the next term, use campus services (e.g.
      libraries, health services, recreational sports facilities, Class Pass bus travel, Career Center, etc.), receive final
      grades, or obtain official campus transcripts.</p>
      <p>Please feel free to contact the Center for Student Conduct at 510-643-9069 or email
      <a href="mailto:studentconduct@berkeley.edu">studentconduct@berkeley.edu</a> for more information regarding your block.</p>
      EOS

      student_health_registrar = <<-EOS
      <p>Your registration as an official Berkeley student is blocked by the Office of the Registrar at the request of the
      Student Health Service. Though you may enroll in classes for the current term, until this block is cleared you
      <strong>cannot</strong> enroll in classes for the next term, use campus services (e.g. libraries, health services, recreational
      sports facilities, Class Pass bus travel, Career Center, etc.), receive final grades, or obtain official campus transcripts.</p>
      <p>To clear this block, visit University Health Service at the <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?tang">Tang
      Center</a>, 2222 Bancroft Way.</p>
      EOS

      student_health_uhs = <<-EOS
      <p>Your registration as an official Berkeley student is blocked by University Health Services due to a medical condition
      that prevents you from attending classes. Though you may enroll in classes for the current term, until this block
      is cleared you <strong>cannot</strong> enroll in classes for  the next term, use campus services (e.g. library, RSF, Class Pass,
      Career Center), receive final grades, or obtain formal campus transcripts.</p>
      <p>To clear this block, please contact <a href="http://www.uhs.berkeley.edu/students/counseling/socialservices.shtml">UHS
      Social Services</a>.</p>
      EOS

      student_health_hb = <<-EOS
      <p>Your registration as an official Berkeley student is blocked by University Health Services because you do not have
      evidence of a Hepatitis B vaccine on file. Though you may enroll in classes for the current term, until this block
      is cleared you <strong>cannot</strong> enroll in classes for  the next term, use campus services (e.g. library, RSF, Class Pass,
      Career Center), receive final grades, or obtain formal campus transcripts.</p>

      <p>To clear this block, please follow the instructions on the
      <a href="http://www.uhs.berkeley.edu/students/immunization/hepatitisb.shtml">Hepatitis B: Condition of Enrollment</a> page.</p>
      EOS

      academic_grad = <<-EOS
      <p>Your enrollment is blocked by the Graduate Division for an academic reason. This block will prevent you from enrolling
      in classes at the University.</p>
      EOS

      academic_cnr = <<-EOS
      <p>Your enrollment is blocked by the Office of Instruction and Student Affairs in the College of Natural Resources because
      you need to speak with an academic advisor. Until this block is cleared, you <strong>cannot</strong> enroll in classes for the next term
      term. If you are not enrolled in classes, you will not be an officially registered student. You must be an officially
      registered student to use campus services (e.g. libraries, health services, recreational sports facilities, Class Pass bus
      travel, Career Center, etc.), receive final grades, or obtain official campus transcripts.</p>
      <p>For more information on this block go to the <a href="http://nature.berkeley.edu/site/oisa.php">Office of Instruction and
      Student Affairs</a>, <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?mulford">260 Mulford Hall</a> Monday - Friday
      8am-12pm p.m. and 1-5 p.m. or call (510) 642-0542.</p>
      EOS

      academic_busadm = <<-EOS
      <p>Your enrollment is blocked by the Haas School of Business Undergraduate Program because you have failed to comply with
      one or more of their undergraduate program policies. Until this block is cleared, you <strong>cannot</strong> enroll in classes for the
      next term and may not receive your advisor code. If you are not enrolled in classes, you will not be an officially
      registered student. You must be an officially registered student to use campus services (e.g. libraries, health services,
      recreational sports facilities, Class Pass bus travel, Career Center, etc.), receive final grades, or obtain official
      campus transcripts.</p>
      <p>To clear this block please contact Barbara Felkins in the Haas Undergraduate Program Office at
      <a href="mailto:felkins@haas.berkeley.edu">felkins@haas.berkeley.edu</a> or (510) 642-1421.</p>
      EOS

      academic_ced = <<-EOS
      <p>Your enrollment has is blocked by the Office of Undergraduate Advising in the College of Environmental Design due to an
      academic problem. Unless this block is cleared, you <strong>cannot</strong> enroll in classes for the next term. If you are not
      enrolled in classes, you will not be an officially registered student. You must be an officially registered student to use
      campus services (e.g. libraries, health services, recreational sports facilities, Class Pass bus travel, Career Center, etc.),
      receive final grades, or obtain official campus transcripts.</p>
      <p>For more information, meet with an adviser in 250 Wurster Hall. For adviser contact information, see
      <a href="http://ced.berkeley.edu/ced/students/undergraduate-advising/">http://ced.berkeley.edu/ced/students/undergraduate-advising/.</a></p>
      EOS

      academic_engin = <<-EOS
      <p>Your enrollment is blocked by Engineering Student Services for an academic reason. Until this block is cleared, you
      <strong>cannot</strong> enroll in classes for the next term. If you are not enrolled in classes, you will not be an officially
      registered student. You must be an officially registered student to use campus services (e.g. libraries, health
      services, recreational sports facilities, Class Pass bus travel, Career Center, etc.), receive final grades, or
      obtain official campus transcripts.</p>
      <p>For the specific nature of the academic issue(s) that resulted in this block and for instructions on how to clear it,
      <a href="http://coe.berkeley.edu/ESS">schedule an appointment</a> to meet with with your ESS Advisor in
      <a href="http://www.google.com/url?q=http%3A%2F%2Fwww.berkeley.edu%2Fmap%2F3dmap%2F3dmap.shtml%3Fbechtel&sa=D&sntz=1&usg=AFQjCNGKye4-S5sNjzyDQnu3mx3xYZOI6A">
      230 Bechtel Center</a>.</p>
      EOS

      academic_chem = <<-EOS
      <p>Your enrollment is blocked by the College of Chemistry. Until this block is cleared, you <strong>cannot</strong> enroll in classes
      for the next term. If you are not enrolled in classes, you will not be an officially registered student. You
      must be an officially registered student to use campus services (e.g. libraries, health services, recreational sports
      facilities, Class Pass bus travel, Career Center, etc.), receive final grades, or obtain official campus transcripts.</p>
      <p>To clear this block, contact your staff advisor in the <a href="http://chemistry.berkeley.edu/student_info/undergrad_info/people/office_directory.php">
      College of Chemistry Undergraduate Advising Office</a>.</p>
      EOS

      academic_law = <<-EOS
      <p>Your enrollment is blocked by the Law School Registrar because you have not submitted an official transcript showing
      the award of your bachelor's degree. Until this block is cleared, you <strong>cannot</strong> enroll in classes for the next term.
      If you are not enrolled in classes, you will not be an officially registered student. You must be an officially registered
      student to use campus services (e.g. libraries, health services, recreational sports facilities, Class Pass bus travel,
      Career Center, etc.), receive final grades, or obtain official campus transcripts.</p>
      <p>To clear this block please submit an official copy of your undergraduate transcript to the Law School Registrar,
      <a href="http://www.google.com/url?q=http%3A%2F%2Fwww.berkeley.edu%2Fmap%2F3dmap%2F3dmap.shtml%3Fboalt&sa=D&sntz=1&usg=AFQjCNGhnjxiepqkZDQ43OadhOwinxR0Wg">270
      Boalt Hall</a>, Berkeley, CA  94720-7200.</p>
      EOS

      rnc_ced = <<-EOS
      <p>Your enrollment is blocked by the Office of Undergraduate Advising in the College of Environmental Design for failure
      to complete the Reading and Composition requirement by the designated deadline. Until this block is cleared, you <strong>cannot</strong>
      enroll in classes for the next term. If you are not enrolled in classes, you will not be an officially registered
      student. You must be an officially registered student to use campus services (e.g. libraries, health services, recreational
      sports facilities, Class Pass bus travel, Career Center, etc.), receive final grades, or obtain official campus transcripts.</p>
      <p>To clear this block, meet with an advisor in <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?wurster">250 Wurster
      Hall</a> or <a href="http://ced.berkeley.edu/ced/students/undergraduate-advising/">contact your major advisor</a>.</p>
      EOS

      rnc_engin = <<-EOS
      <p>Your enrollment is blocked by the College of Engineering for failure to complete the Reading and Composition requirement
      by the designated deadline. Until this block is cleared, you <strong>cannot</strong> enroll in classes for the next term. If you are
      not enrolled in classes, you will not be an officially registered student. You must be an officially registered student to
      use campus services (e.g. libraries, health services, recreational sports facilities, Class Pass bus travel, Career Center,
      etc.), receive final grades, or obtain official campus transcripts.</p>
      <p>For instructions on how to clear this block, <a href="http://coe.berkeley.edu/ESS">schedule an appointment</a> to meet
      with your ESS Advisor in
      <a href="http://www.google.com/url?q=http%3A%2F%2Fwww.berkeley.edu%2Fmap%2F3dmap%2F3dmap.shtml%3Fbechtel&sa=D&sntz=1&usg=AFQjCNGKye4-S5sNjzyDQnu3mx3xYZOI6A">230
      Bechtel Center</a>.</p>
      EOS

      rnc_chem = <<-EOS
      <p>Your enrollment is blocked by the College of Chemistry because you have not completed the Reading and Composition
      requirement for your major. Until this block is cleared, you <strong>cannot</strong> enroll in classes for the next term. If you
      are not enrolled in classes, you will not be an officially registered student. You must be an officially registered student
      to use campus services (e.g. libraries, health services, recreational sports facilities, Class Pass bus travel, Career
      Center, etc.), receive final grades, or obtain official campus transcripts.</p>
      <p>To clear this block, contact your staff advisor in the
      <a href="http://chemistry.berkeley.edu/student_info/undergrad_info/people/office_directory.php">College of Chemistry
      Undergraduate Advising Office</a>.</p>
      EOS

      rnc_lns = <<-EOS
      <p>Your enrollment is blocked by the College of Letters & Science because you have not completed the Reading and Composition
      requirement for your major. Until this block is cleared, you <strong>cannot</strong> enroll in classes for the next term. If you are
      not enrolled in classes, you will not be an officially registered student. You must be an officially registered student
      to use campus services (e.g. libraries, health services, recreational sports facilities, Class Pass bus travel, Career
      Center, etc.), receive final grades, or obtain official campus transcripts.</p>
      <p>To clear this block, you will need to meet with an advisor using one of these options:</p>
      <ul>
      <li>Drop-in advising (first come, first-served): Monday - Friday, 9 a.m. - 2:30 p.m. and Wednesdays 1 - 3 p.m.</li>
      <li>In-person, phone and Skype appointments: Monday - Friday, 9 a.m. - 4 p.m. Call (510) 642-1483 a week in advance to
      schedule.</li>
      </ul>
      <p>You must choose one of these options as we will not release the block via email or phone. Our office is located in
      <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?evans">206 Evans Hall</a>.</p>
      EOS

      minimum_progress = <<-EOS
      <p>Your enrollment is blocked by the College of Letters & Science because you did not enroll in the required minimum
      number of units during the current term although a previous warning had been sent to you. Until this block is cleared,
      you <strong>cannot</strong> enroll in classes for the next term. If you are not enrolled in classes, you will not be an officially
      registered student. You must be an officially registered student to use campus services (e.g. libraries, health services,
      recreational sports facilities, Class Pass bus travel, Career Center, etc.), receive final grades, or obtain official
      campus transcripts.</p>
      <p>To clear this block, you will need to meet with an advisor using one of these options:</p>
      <ul>
      <li>Drop-in advising (first come, first-served): Monday - Friday, 9 a.m. - 2:30 p.m. and Wednesdays 1 - 3 p.m.</li>
      <li>In-person, phone and Skype appointments: Monday - Friday, 9 a.m. - 4 p.m. Call (510) 642-1483 a week in advance to
      schedule.</li>
      </ul>
      <p>Be sure to bring a completed <a href="http://ls-advise.berkeley.edu/fp/SSLCt.pdf">Minimum Study List Contract</a> with
      you to your advising appointment. You must choose one of the options above as we will not release the block via email or
      phone. Our office is located in <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?evans">206 Evans Hall</a>.</p>
      <p>Important notes:</p>
      <ul>
      <li>The College of Letters and Science requires you to maintain 13 units each semester. If you have received approval
      from the College for a <a href="http://ls-advise.berkeley.edu/faq/enroll13.html">reduced course load</a>, you must maintain
      the number of units for which you have been approved.</li>
      <li>If you are a current degree candidate and will graduate at the end of this term, you must visit us in
      <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?evans">206 Evans Hall</a> for approval to go below 13 units.</li>
      <li>If you believe our records are inaccurate, please contact the college advising office at (510) 642-1483.</li>
      </ul>
      EOS

      undeclared_senior = <<-EOS
      <p>Your registration has been blocked for next term by the College of Letters & Science because you have not yet declared
      a major. Academic Senate regulations require that all students in the College of Letters and Science declare a major by the
      beginning of their junior year.  Failure to do so upon reaching senior status might adversely affect progress toward your
      degree. Our records indicate that you will reach senior status after completion of current term and have not yet declared
      a major.</p>
      <p>Next steps to clear this block:</p>
      <ul>
      <li>Contact your intended major department immediately and declare your major. Once you've declared a major, visit us in
      <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?evans">206 Evans Hall</a> to have your block released.</li>
      <li>If you are unable to declare at this time, contact your intended major department immediately and fill out the
      <a href="http://ls-advise.berkeley.edu/fp/09Intent_Declare.pdf">Conditions to Declare form</a>. Once you have completed this
      form visit us in <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?evans">206 Evans Hall</a> to discuss your continued
      enrollment with a college adviser.</li>
      <li>If you are having difficulty deciding on a major, please contact our office at
      <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?evans">206 Evans Hall</a> to discuss your situation with a college
      adviser.</li>
      <li>If you believe that our information is incorrect, please call (510) 642-1483 or visit
      <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?evans">206 Evans Hall</a> so that your record may be updated.</li>
      <p><a href="http://ls-advise.berkeley.edu/OUAhome.html">View hours of operation and advising options &raquo;</a></p>
      <p>Your prompt attention to this matter will benefit your academic progress since it affects your ability to enroll in
      classes and be officially registered with the University. Being official registered impacts your ability to use campus
      services (e.g. libraries, health services, recreational sports facilities, Class Pass bus travel, Career Center), receive
      final grades, or obtain official campus transcripts.</p>
      EOS

      unauth_short_study = <<-EOS
      <p>Your registration has been blocked for next term by the College of Letters & Science because you did not enroll in
      the required minimum number of units during the current term although a previous warning had been sent to you. Until
      this block is cleared, you <strong>cannot</strong> enroll in classes for the next term. If you are not enrolled in classes, you
      will not be an officially registered student. You must be an officially registered student to use campus services (e.g.
      libraries, health services, recreational sports facilities, Class Pass bus travel, Career Center, etc.), receive final
      grades, or obtain official campus transcripts.</p>
      <p>To clear this block, you will need to meet with an advisor using one of these options:</p>
      <ul>
      <li>Drop-in advising (first come, first-served): Monday - Friday, 9 a.m. - 2:30 p.m. and Wednesdays 1 - 3 p.m.</li>
      <li>In-person, phone and Skype appointments: Monday - Friday, 9 a.m. - 4 p.m. Call (510) 642-1483 a week in advance to
      schedule.</li>
      </ul>
      <p>Be sure to bring a completed <a href="http://ls-advise.berkeley.edu/fp/SSLCt.pdf">Minimum Study List Contract</a> with
      you to your advising appointment. You must choose one of the options above as we will not release the block via email or
      phone. Our office is located in <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?evans">206 Evans Hall</a>.</p>
      <p>Important notes:</p>
      <ul>
      <li>The College of Letters and Science requires you to maintain 13 units each semester. If you have received approval
      from the College for a <a href="http://ls-advise.berkeley.edu/faq/enroll13.html">reduced course load</a>, you must maintain
      the number of units for which you have been approved.</li>
      <li>If you are a current degree candidate and will graduate at the end of this term, you must visit us in
      <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?evans">206 Evans Hall</a> for approval to go below 13 units.</li>
      <li>If you believe our records are inaccurate, please contact the college advising office at (510) 642-1483.</li>
      </ul>
      EOS

      excess_units = <<-EOS
      <p>Your registration has been blocked for next term by the College of Letters & Science because you have exceeded the
      maximum number semesters and/or units allowed. By the end of this semester, you will have completed eight or more semesters
      and exceeded 130 units. Until this block is cleared, you <strong>cannot</strong> enroll in classes for the next term. If you are not
      enrolled in classes, you will not be an officially registered student. You must be an officially registered student to use
      campus services (e.g. libraries, health services, recreational sports facilities, Class Pass bus travel, Career Center, etc.),
      receive final grades, or obtain official campus transcripts.</p>
      <p>The College limits students to eight semesters of enrollment including all institutions attended, or enrollment through
      the semester in which students exceed 130 units, whichever comes last. For the purpose of calculating the total units and
      terms you have completed, summer session is not considered a semester and high school enrichment units are not included.</p>
      <p>Next steps:</p>
      <ul>
      <li>If you intend to graduate at the end of this term, please visit
      <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?evans">206 Evans Hall</a> and declare your candidacy.</li>
      <li>Contact us if you would like to meet with an adviser to discuss the options you have to complete your degree.</li>
      </ul>
      <p>If you believe our records are inaccurate, please call us at (510) 642-1483.</p>
      EOS

      double_major = <<-EOS
      <p>Your registration has been blocked for next term by the College of Letters & Science because you have declared as a
      double major and you are in your final eligible semester</p>
      <p>Next steps:</p>
      <ul>
      <li>No action is required.</li>
      <li>This is a standard block on your record as an approved double major that is placed against the semester following
      your final eligible semester, and will restrict you from enrolling in classes {next term}.  Reference
      <a href="http://ls-advise.berkeley.edu/major/double.html">Double Majors and Simultaneous Degrees</a></li>
      </ul>
      <p>If you believe that our information is incorrect, or you would like to discuss your situation with an advisor,
      please call (510) 642-1483 or visit <a href="http://www.berkeley.edu/map/3dmap/3dmap.shtml?evans">206 Evans Hall</a>.</p>
      <p><a href="http://ls-advise.berkeley.edu/OUAhome.html">View hours of operation and advising options &raquo;</a></p>
      EOS

      {
        7 => ll_text,
        8 => lf_text,
        16 => cars_text,
        18 => housing_text,
        40 => admissions_ugrad,
        42 => admissions_grad,
        44 => status_lapse,
        46 => education_abroad,
        48 => misconduct,
        52 => {
          'OR' => student_health_registrar,
          'TANG' => student_health_uhs
        },
        53 => student_health_hb,
        60 => {
          'GRAD' => academic_grad,
          'CNR' => academic_cnr,
          'BUSADM' => academic_busadm,
          'CED' => academic_ced,
          'ENGIN' => academic_engin,
          'CHEM' => academic_chem,
          'LAW' => academic_law,
        },
        62 => minimum_progress,
        64 => undeclared_senior,
        66 => unauth_short_study,
        68 => excess_units,
        70 => double_major,
        74 => {
          'CED' => rnc_ced,
          'ENGIN' => rnc_engin,
          'CHEM' => rnc_chem,
          'LNS' => rnc_lns,
        }
      }
    end

    def self.init_reason_translation_hash
      {
        7 => 'Long-Term Loan',
        8 => 'Library Fine',
        16 => 'CARS',
        18 => 'Housing',
        40 => 'Admissions - Undergraduate',
        42 => 'Admissions - Graduate',
        44 => 'Status Lapse',
        46 => 'Education Abroad',
        48 => 'Misconduct',
        50 => 'Miscellaneous',
        52 => 'Student Health',
        53 => 'Student Health - HB',
        60 => 'Academic',
        62 => 'Minimum Progress',
        64 => 'Undeclared Senior',
        66 => 'Unauthorized Short Study',
        68 => 'Excess Units',
        70 => 'Double Major',
        72 => 'Semester Out',
        74 => 'Reading and Composition',
      }
    end

    def self.init_office_translation_hash
      {
        'LIBRARY' => 'Library',
        'TANG' => 'Tang Student Health Services',
        'SUMMER' => 'Summer Session Office',
        'TELECOM' => 'Telecommunications',
        'BPS' => 'Billing and Payment Services',
        'CASHIER' => 'University Cashier',
        'HOUSING' => 'Housing Office',
        'OR' => 'Office of the Registrar - Registration',
        'OUARS' => 'Office of the Registrar - Admissions',
        'GRAD' => 'Graduate Division',
        'GRADADM' => 'Graduate Admissions',
        'NATIVE' => 'Native American Studies',
        'CHICANO' => 'Chicano Studies',
        'ASIAN' => 'Asian American Studies',
        'CNR' => 'College of Natural Resources',
        'BUSADM' => 'Business Administration',
        'CED' => 'College of Environmental Design',
        'ENGIN' => 'College of Engineering',
        'CHEM' => 'College of Chemistry',
        'LNS' => 'College of Letters and Science',
        'LAW' => 'School of Law',
        'JUD AFF' => 'Judicial Affairs',
      }
    end

    def self.translate_to_message(reason_code, office)
      @message_translation_hash ||= init_message_translation_hash
      response = @message_translation_hash[reason_code.to_i]
      if response.kind_of?(Hash)
        response = response[office]
      end
      if response.blank?
        Rails.logger.warn "#{self.name} undefined message for reason_code #{reason_code}, office_code: #{office}"
        response = <<-EOS
        <p>You have received an unknown or invalid Block type and reason code #{reason_code} from office code #{office}.
        To clear this block, contact Cal Student Central at 120 Sproul Hall, or call (510) 664-9181.</p>
        EOS
      end
      response.strip
    end

    def self.translate_to_type_and_reason(reason_code)
      begin
        code = Integer(reason_code.strip, 10)
        block_type = ''
        if (code <= 30)
          block_type = 'Financial'
        elsif (code >= 40 && code < 60)
          block_type = 'Administrative'
        else
          block_type = 'Academic'
        end

        @reason_translation_hash ||= init_reason_translation_hash
        reason = @reason_translation_hash[code]
        if reason.blank?
          Rails.logger.warn "#{self.name} unknown reason type for #{code}"
          reason = 'Unknown'
        end

        {
          reason: reason,
          type: block_type,
        }

      rescue ArgumentError => e
        Rails.logger.warn "#{self.name}: Unable to translate translate_type_and_reason for #{reason_code}"
        {
          reason: 'Unknown',
          type: 'Unknown',
        }
      end

    end

    def self.translate_office_code(office_code)
      return 'Library' if office_code.blank?
      @office_translation_hash ||= init_office_translation_hash
      office = @office_translation_hash[office_code]
      if office.blank?
        Rails.logger.warn "#{self.name}: Unknown office code #{office_code}"
        office = 'Bearfacts'
      end
      office
    end
  end
end
