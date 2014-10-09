require "spec_helper"

describe Berkeley::CourseOptions do
  subject { Berkeley::CourseOptions.nested?(primary['course_option'], primary['section_num'], secondary) }

  context 'when no nesting defined' do
    let(:primary) { {'course_option' => 'UNKN', 'section_num' => '001'} }
    let(:secondary) { {'section_num' => '101', 'instruction_format' => 'DIS'} }
    it {should be_falsey}
  end

  context 'when A1' do
    let(:primary) { {'course_option' => 'A1', 'section_num' => '001'} }
    context 'when a matching instruction format' do
      let(:secondary) { {'section_num' => '999', 'instruction_format' => 'DIS'} }
      it {should be_truthy}
    end
    context 'when one of the non-enrolled formats' do
      let(:secondary) { {'section_num' => '101', 'instruction_format' => 'SUP'} }
      it {should be_falsey}
    end
  end

  context 'when E1' do
    let(:primary) { {'course_option' => 'E1', 'section_num' => '002'} }
    context 'when a digit match' do
      let(:secondary) { {'section_num' => '201', 'instruction_format' => 'DIS'} }
      it {should be_truthy}
    end
    context 'when not a digit match' do
      let(:secondary) { {'section_num' => '101', 'instruction_format' => 'DIS'} }
      it {should be_falsey}
    end
    context 'when one of the non-enrolled formats' do
      let(:secondary) { {'section_num' => '201', 'instruction_format' => 'VOL'} }
      it {should be_falsey}
    end
  end

  context 'when H1' do
    let(:primary) { {'course_option' => 'H1', 'section_num' => '002'} }
    context 'when a digit match' do
      let(:secondary) { {'section_num' => '121', 'instruction_format' => 'LAB'} }
      it {should be_truthy}
    end
    context 'when not a digit match' do
      let(:secondary) { {'section_num' => '202', 'instruction_format' => 'LAB'} }
      it {should be_falsey}
    end
  end

  context 'when H2' do
    let(:primary) { {'course_option' => 'H2', 'section_num' => '002'} }
    context 'when a range match' do
      let(:secondary) { {'section_num' => '102', 'instruction_format' => 'LAB'} }
      it {should be_truthy}
    end
    context 'when not a range match' do
      let(:secondary) { {'section_num' => '112', 'instruction_format' => 'LAB'} }
      it {should be_falsey}
    end
  end

  context 'when I1' do
    let(:primary) { {'course_option' => 'I1', 'section_num' => '002'} }
    context 'when a digit match on DIS' do
      let(:secondary) { {'section_num' => '020', 'instruction_format' => 'DIS'} }
      it {should be_truthy}
    end
    context 'when not a digit match on DIS' do
      let(:secondary) { {'section_num' => '202', 'instruction_format' => 'DIS'} }
      it {should be_falsey}
    end
    context 'when a digit match on LAB' do
      let(:secondary) { {'section_num' => '201', 'instruction_format' => 'LAB'} }
      it {should be_truthy}
    end
    context 'when not a digit match on LAB' do
      let(:secondary) { {'section_num' => '122', 'instruction_format' => 'LAB'} }
      it {should be_falsey}
    end
  end

  context 'when T1' do
    let(:primary) { {'course_option' => 'T1', 'section_num' => '002'} }
    context 'when a range match' do
      let(:secondary) { {'section_num' => '021', 'instruction_format' => 'DIS'} }
      it {should be_truthy}
    end
    context 'when not a range match' do
      let(:secondary) { {'section_num' => '121', 'instruction_format' => 'DIS'} }
      it {should be_falsey}
    end
  end

  # Backwards ranges, yet.
  context 'when U2' do
    let(:primary) { {'course_option' => 'U2', 'section_num' => '002'} }
    context 'when a range match' do
      let(:secondary) { {'section_num' => '201', 'instruction_format' => 'DIS'} }
      it {should be_truthy}
    end
    context 'when not a range match' do
      let(:secondary) { {'section_num' => '220', 'instruction_format' => 'DIS'} }
      it {should be_falsey}
    end
  end

end
