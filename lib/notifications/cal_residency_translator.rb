class CalResidencyTranslator

  def translate(cal_residency_flag)
    if cal_residency_flag == "Y"
      response = {
          summary: 'Resident',
          explanation: '',
          needsAction: false
      }
    elsif cal_residency_flag == "N"
      response = {
          summary: 'Non-Resident',
          explanation: '<a href="http://registrar.berkeley.edu/establish.html">Establishing California residency</a>',
          needsAction: false
      }
    else
      # The flag is NULL
      response = {
          summary: 'Not received',
          explanation: 'Please <a href="http://registrar.berkeley.edu/Registrar/slrfaq.html">submit documentation about your residency status</a> as soon as possible.',
          needsAction: true
      }
    end
    response ||= {}
  end

end
