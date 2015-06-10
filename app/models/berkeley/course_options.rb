module Berkeley
  module CourseOptions
    extend self

    # An official instructor of a primary section will generally assume implicit
    # instructor-level access for some of the course's secondary sections. The
    # class's 'course_option' determines which secondary sections are included.
    #
    # We need to support a maddening variety of course options and rules. Here
    # are the main types.
    #
    # A) Include all secondary sections (given a proper section format code).
    #
    #    Example:
    #      'A1' => [{formats: ['DIS']}]
    #
    #    Rule: Any 'A1' primary section will give access to any secondary section whose
    #    format code is 'DIS'. But secondary sections whose format code is 'VOL' will
    #    not be included.
    #
    # B) Include secondary sections (with the proper section format codes) whose section number
    #    matches one digit of the primary section number.
    #
    #    Example:
    #      'E1' => [{formats: ['DIS'], primary: 2, secondary: 0}]
    #
    #    Rule: The third digit of the primary section number ('2' in '002') needs to match the first
    #    digit of the secondary section number ('2' in '233').
    #
    # C) Include secondary sections whose section number matches a substring of digits
    #    in the primary section number.
    #
    #    Example:
    #      'T1' => [{formats: ['DIS'], primary: 1..2, secondary: 0..1}]
    #
    #    Rule: The last two digits of the primary section number ('02' in '102') need to match
    #    the first two digits of the secondary section number ('02' in '026').
    #
    # D) Include secondary sections whose section number matches a reversed substring
    #    of digits in the primary section number.
    #
    #    Example:
    #      'U2' => [{formats: ['DIS'], primary: 1..2, secondary: 0..1, reverse:true}],
    #
    #    Rule: The third and second digits of the primary section number ('10' in '310') need
    #    to match the first and second digits of the secondary section number ('01' in '018').
    #
    # E) And sometimes different format codes need different substring checks.
    #
    #    Example:
    #     'I1' => [{formats: ['DIS'], primary: 2, secondary: 1},
    #              {formats: ['LAB'], primary: 2, secondary: 0}]
    #
    #    Rule: A 'DIS' secondary section needs to match on the second digit ('3' in '132')
    #    but a 'LAB' secondary section needs to match on the first digit ('3' in '302').

    # Since there are about 80 of these course options, we'd like to describe them
    # compactly for (relatively) easier maintenance.
    # The mapping structure below has the following parts.
    #   key = the course option code
    #   'formats' = the secondary section format codes which might be included.
    #   'primary' = the character position or range of interest in the primary section number.
    #   'secondary' = the character position or range of interest in the secondary section number.
    MAPPING = {
      'A1' => [{formats: ['DIS']}],
      'A2' => [{formats: ['CLC']}],
      'A3' => [{formats: ['LEC'], primary: 1, secondary: 0}],
      'B1' => [{formats: ['LAB']}],
      'B2' => [{formats: ['SEM']}],
      'B3' => [{formats: ['DIS', 'LEC']}],
      'C1' => [{formats: ['DIS', 'LAB']}],
      'C2' => [{formats: ['TUT']}],
      'C3' => [{formats: ['LEC'], primary: 2, secondary: 2}],
      'C9' => [{formats: ['DIS', 'LAB']}],
      'D1' => [{formats: ['DIS', 'LAB']}],
      'D2' => [{formats: ['DEM', 'LAB']}],
      'D3' => [{formats: ['LAB', 'REC']}],
      'D9' => [{formats: ['DIS', 'LAB']}],
      'E1' => [{formats: ['DIS'], primary: 2, secondary: 0}],
      'E2' => [{formats: ['REC', 'TUT']}],
      'E3' => [{formats: ['FLD', 'LAB']}],
      'F1' => [{formats: ['LAB'], primary: 2, secondary: 0}],
      'F2' => [{formats: ['DEM', 'LAB']}],
      'F3' => [{formats: ['LAB', 'REC']}],
      'G1' => [{formats: ['DIS'], primary: 2, secondary: 1}],
      'G2' => [{formats: ['DIS', 'WOR'], primary: 2, secondary: 0}],
      'G3' => [{formats: ['SES'], primary: 2, secondary: 0}],
      'G4' => [{formats: ['DEM', 'LAB'], primary: 2, secondary: 0}],
      'H1' => [{formats: ['LAB'], primary: 2, secondary: 1}],
      'H2' => [{formats: ['LAB'], primary: 1..2, secondary: 1..2}],
      'H3' => [{formats: ['WOR'], primary: 2, secondary: 0}],
      'I1' => [
        {formats: ['DIS'], primary: 2, secondary: 1},
        {formats: ['LAB'], primary: 2, secondary: 0}
      ],
      'I2' => [{formats: ['FLD', 'LAB']}],
      'I3' => [{formats: ['DEM', 'LAB']}],
      'J1' => [
        {formats: ['DIS'], primary: 2, secondary: 0},
        {formats: ['LAB'], primary: 2, secondary: 1}
      ],
      'J2' => [{formats: ['LEC']}],
      'J3' => [{formats: ['WBD']}],
      'K1' => [{formats: ['DIS', 'LAB'], primary: 2, secondary: 0}],
      'K2' => [{formats: ['DIS', 'LAB']}],
      'K3' => [{formats: ['DEM'], primary: 2, secondary: 0}],
      'L1' => [{formats: ['DIS', 'LAB'], primary: 2, secondary: 0}],
      'L2' => [{formats: ['DEM', 'LAB']}],
      'L3' => [{formats: ['LEC', 'WBD', 'WBL']}],
      # M1 deleted from system.
      'M2' => [{formats: ['FLD'], primary: 2, secondary: 0}],
      'M3' => [{formats: ['LAB', 'STD']}],
      # N1 deleted from system.
      'N2' => [{formats: ['DIS', 'FLD']}],
      'N3' => [{formats: ['DIS'], primary: 1..2, secondary: 1..2}],
      'O1' => [{formats: ['DIS', 'LAB'], primary: 2, secondary: 0}],
      'O2' => [{formats: ['DIS', 'LAB']}],
      'O3' => [{formats: ['CON']}],
      'P1' => [{formats: ['DIS', 'LAB'], primary: 2, secondary: 0}],
      # Doc is inconsistent; bSpace code doesn't match; no examples in DB.
      'P2' => [{formats: ['DIS'], primary: 2, secondary: 2}],
      'P3' => [{formats: ['GRP']}],
      'Q1' => [{formats: ['DIS', 'LAB']}],
      'Q2' => [{formats: ['LEC'], primary: 2, secondary: 0}],
      'Q3' => [{formats: ['DIS', 'FLD']}],
      'R1' => [{formats: ['DEM', 'LAB']}],
      'R2' => [{formats: ['WOR']}],
      'S1' => [{formats: ['REC']}],
      'S2' => [{formats: ['DIS', 'SEM']}],
      'T1' => [{formats: ['DIS'], primary: 1..2, secondary: 0..1}],
      'T2' => [{formats: ['DIS', 'LEC']}],
      'U1' => [{formats: ['STD'], primary: 2, secondary: 0}],
      'U2' => [{formats: ['DIS'], primary: 1..2, secondary: 0..1, reverse: true}],
      'V1' => [{formats: ['REC'], primary: 2, secondary: 0}],
      # bSpace code incorrectly specifies LEC instead of LAB.
      'V2' => [{formats: ['DIS', 'LAB']}],
      'W1' => [{formats: ['DIS', 'WOR'], primary: 2, secondary: 0}],
      'W2' => [{formats: ['QUZ']}],
      'X1' => [{formats: ['DEM']}],
      'X2' => [{formats: ['DIS', 'LAB']}],
      'Y1' => [{formats: ['INT']}],
      'Y2' => [{formats: ['LAB', 'LEC']}],
      'Z1' => [{formats: ['FLD']}],
      'Z2' => [{formats: ['SES']}],
      'Z9' => [{formats: ['DIS', 'LAB']}]
    }

    def nested?(course_option, primary_section_number, secondary_section_number, secondary_instruction_format)
      mapping = MAPPING[course_option]
      return false if mapping.nil?
      return false unless match = mapping.find { |m| m[:formats].include?(secondary_instruction_format) }
      return true if match[:primary].nil?
      match_string = primary_section_number[match[:primary]]
      match_string.reverse! if match[:reverse]
      return match_string == secondary_section_number[match[:secondary]]
    end

  end
end
