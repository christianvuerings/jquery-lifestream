module Berkeley
  module GradeOptions
    extend self
    include ClassLogger

    # See http://registrar.berkeley.edu/Records/gradeskey.html for background.
    #
    # A course's "credit_code" describes how the student's grade transcript should be interpreted
    # and also determines whether anything other than a letter grade is possible.
    #
    # An enrollment's "pnp_flag" determines whether a non-letter-grade option has been chosen for
    # a particular course.
    #
    # More or less.

    def grade_option_for_enrollment(credit_code, pnp_flag)
      credit_code.strip! if credit_code
      pnp_flag.strip! if pnp_flag
      case pnp_flag
        when nil, '', 'N'
          case credit_code
            when nil, '', 'PF', 'SF', '2T', '3T', 'TT', 'PT', 'ST'
              'Letter'
            when 'PN'
              'P/NP'
            when 'SU'
              'S/U'
            when 'T1', 'T2', 'T3', 'TP', 'TS', 'TX'
              'IP'
            else
              ''
          end
        when 'Y'
          case credit_code
            when nil, '', 'PF', 'PN'
              'P/NP'
            when 'SF', 'SU'
              'S/U'
            else
              ''
          end
        else
          logger.warn("Unknown CRED_CD or PNP_FLAG: '#{credit_code}', '#{pnp_flag}' ")
          ''
      end
    end

  end
end
