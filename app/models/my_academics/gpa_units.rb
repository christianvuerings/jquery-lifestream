module MyAcademics
  class GpaUnits
    include AcademicsModule

    def merge(data)
      student_info = CampusOracle::Queries.get_student_info(@uid) || {}
      return data if student_info.nil?

      data[:gpaUnits] = {
        cumulativeGpa: student_info['cum_gpa'].nil? ? nil: student_info['cum_gpa'].to_f,
        totalUnits: student_info['tot_units'].nil? ? nil : student_info['tot_units'].to_f,
        totalUnitsAttempted: student_info['lgr_tot_attempt_unit'].nil? ? nil : student_info['lgr_tot_attempt_unit'].to_f
      }
    end
  end
end
