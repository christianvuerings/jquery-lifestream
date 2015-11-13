module Berkeley
  module CalResidency
    extend self
    include ClassLogger

    RESIDENCY_UNSTARTED_MESSAGE = 'Please <a href="https://or.berkeley.edu/myresidency/">submit your Statement of Legal Residence</a>. ' +
      'See <a href="http://registrar.berkeley.edu/current_students/residency.html">this page</a> for more information.'
    RESIDENCY_INCOMPLETE_MESSAGE = 'Please <a href="https://or.berkeley.edu/myresidency/">submit your documentation</a> to the Residence Affairs Unit in the Office of the Registrar. ' +
      'See <a href="http://registrar.berkeley.edu/current_students/residency.html">this page</a> for more information.'
    RESIDENCY_COMPLETE_MESSAGE = 'If this status is unexpected, please <a href="https://or.berkeley.edu/myresidency/">check and change your Statement of Legal Residence</a>. ' +
      'See <a href="http://registrar.berkeley.edu/current_students/residency.html">this page</a> for more information.'

    def california_residency_from_campus_row(campus_row)
      fee_resid_cd = campus_row['fee_resid_cd']
      case fee_resid_cd
        when nil, 'E'
          return nil
        when ' ', 'S'
          summary = 'No SLR submitted'
          explanation = RESIDENCY_UNSTARTED_MESSAGE
          needs_action = true
        when 'P'
          summary = 'Case pending'
          explanation = Berkeley::CalResidency::RESIDENCY_INCOMPLETE_MESSAGE
          needs_action = true
        when '1'
          summary = 'SLR started but not completed'
          explanation = Berkeley::CalResidency::RESIDENCY_INCOMPLETE_MESSAGE
          needs_action = true
        when '2'
          # Repress this message during Fall if the student is in the Fall Program for Freshmen
          return nil if campus_row['role_cd'] == '6'
          summary = 'SLR submitted but documentation pending'
          explanation = Berkeley::CalResidency::RESIDENCY_INCOMPLETE_MESSAGE
          needs_action = true
        when 'R'
          summary = 'Resident'
          explanation = ''
          needs_action = false
        when 'N'
          summary = 'Non-Resident'
          explanation = Berkeley::CalResidency::RESIDENCY_COMPLETE_MESSAGE
          needs_action = false
        when 'L'
          summary = 'Provisional resident'
          explanation = Berkeley::CalResidency::RESIDENCY_COMPLETE_MESSAGE
          needs_action = false
        else
          logger.warn "Unknown FEE_RESID_CD '#{fee_resid_cd}' for UID #{campus_row['ldap_uid']}"
          summary = "Unknown code \"#{fee_resid_cd}\""
          explanation = Berkeley::CalResidency::RESIDENCY_COMPLETE_MESSAGE
          needs_action = true
      end
      {
        summary: summary,
        explanation: explanation,
        needsAction: needs_action
      }
    end

  end
end
