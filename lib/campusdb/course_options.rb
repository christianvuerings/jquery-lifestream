module CourseOptions
  extend self

  # An official instructor of a primary section will generally assume implicit
  # instructor-level access for some of the course's secondary sections.
  # There are two main types of nested authorization:
  # A) Include all secondary sections (given a proper section type).
  # B) Include based on one or two digits in the section code (e.g., "001" nests
  #    "101" and "102", but "002" nests "201" and "202").
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
    'P1' => [{formats: ['DIS', 'LAB'], primary: 2, secondary: 0}],
    # Doc is inconsistent; bSpace code doesn't match; no examples in DB.
    'P2' => [{formats: ['DIS'], primary: 2, secondary: 2}],
    'Q1' => [{formats: ['DIS', 'LAB']}],
    'Q2' => [{formats: ['LEC'], primary: 2, secondary: 0}],
    'R1' => [{formats: ['DEM', 'LAB']}],
    'R2' => [{formats: ['WOR']}],
    'S1' => [{formats: ['REC']}],
    'S2' => [{formats: ['DIS', 'SEM']}],
    'T1' => [{formats: ['DIS'], primary: 1..2, secondary: 0..1}],
    'T2' => [{formats: ['DIS', 'LEC']}],
    'U1' => [{formats: ['STD'], primary: 2, secondary: 0}],
    'U2' => [{formats: ['DIS'], primary: 1..2, secondary: 0..1, reverse:true}],
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

  def nested?(course_option, primary_section_number, secondary_section)
    mapping = MAPPING[course_option]
    return false if mapping.nil?
    return false unless match_idx = mapping.index{|m| m[:formats].include?(secondary_section['instruction_format'])}
    match = mapping[match_idx]
    return true if match[:primary].nil?
    match_string = primary_section_number[match[:primary]]
    match_string.reverse! if match[:reverse]
    return match_string == secondary_section['section_num'][match[:secondary]]
  end

end
