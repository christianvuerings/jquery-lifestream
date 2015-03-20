require "spec_helper"

describe Canvas::CourseSections do

  let(:canvas_course_id)    { 5 }
  subject                   { Canvas::CourseSections.new(:course_id => canvas_course_id) }

  context 'when providing sections list' do
    it 'returns sections list' do
      response = subject.sections_list
      sections = JSON.parse(response.body)
      expect(sections).to be_an_instance_of Array
      expect(sections.count).to eq 27
      expect(sections[0]['id']).to eq 7
      expect(sections[0]['name']).to eq 'COMPSCI 61B DIS 111'
      expect(sections[0]['course_id']).to eq 5
      expect(sections[0]['sis_section_id']).to eq 'SEC:2014-D-25932'
      expect(sections[0]['sis_course_id']).to eq 'CRS:COMPSCI-61B-2014-D'
      expect(sections[0]['start_at']).to be_nil
      expect(sections[0]['end_at']).to be_nil
      expect(sections[0]['integration_id']).to be_nil
      expect(sections[0]['nonxlist_course_id']).to be_nil
      expect(sections[0]['sis_import_id']).to eq 24

      expect(sections[1]['id']).to eq 32
      expect(sections[1]['name']).to eq 'COMPSCI 61B LAB 023'
      expect(sections[1]['course_id']).to eq 5
      expect(sections[1]['sis_section_id']).to eq 'SEC:2014-D-26001'
      expect(sections[1]['sis_course_id']).to eq 'CRS:COMPSCI-61B-2014-D'
      expect(sections[1]['start_at']).to be_nil
      expect(sections[1]['end_at']).to be_nil
      expect(sections[1]['integration_id']).to be_nil
      expect(sections[1]['nonxlist_course_id']).to be_nil
      expect(sections[1]['sis_import_id']).to eq 24
    end

    it 'forces cache refresh when argument present' do
      uncached_response = double('uncached_response')
      expect(Canvas::CourseSections).to receive(:fetch_from_cache).with(canvas_course_id, true).and_return(uncached_response)
      response = subject.sections_list(true)
      expect(response).to eq uncached_response
    end
  end

  context 'when providing official section identifiers existing within course' do
    let(:course_sections) do
      [
        {'id' => 673, 'course_id' => 482, 'name' => 'COMPSCI 9G SLF 001', 'sis_section_id' => 'SEC:2014-C-7309'},
        {'id' => 674, 'course_id' => 482, 'name' => 'COMPSCI 9G SLF 001', 'sis_section_id' => 'SEC:2014-C-6211'}
      ]
    end
    let(:failed_response) { double('course sections response', :status => 500, :body => '') }
    let(:success_response) { double('course sections response', :status => 200, :body => JSON.generate(course_sections))}

    context 'when course sections request fails' do
      before { allow(subject).to receive(:sections_list).and_return(failed_response) }
      it 'returns empty array' do
        expect(subject.official_section_identifiers).to eq []
      end
    end

    context 'when course sections request returns sections' do
      before { allow(subject).to receive(:sections_list).and_return(success_response) }
      it 'returns canvas course section with ccn and term included' do
        sis_section_ids = subject.official_section_identifiers
        expect(sis_section_ids).to be_an_instance_of Array
        expect(sis_section_ids.count).to eq 2
        expect(sis_section_ids[0]).to eq course_sections[0].merge({:term_yr=>'2014', :term_cd=>'C', :ccn=>'07309'})
        expect(sis_section_ids[1]).to eq course_sections[1].merge({:term_yr=>'2014', :term_cd=>'C', :ccn=>'06211'})
      end

      context 'when course sections returned includes invalid section ids' do
        let(:course_sections) do
          [
              {'id' => 673, 'course_id' => 482, 'name' => 'COMPSCI 9G SLF 001', 'sis_section_id' => 'SEC:2014-C-7309'},
              {'id' => 674, 'course_id' => 482, 'name' => 'COMPSCI 9G SLF 001', 'sis_section_id' => nil},
              {'id' => 675, 'course_id' => 482, 'name' => 'COMPSCI 9G SLF 001', 'sis_section_id' => 'SEC:2014-C-6211'},
              {'id' => 676, 'course_id' => 482, 'name' => 'COMPSCI 9G SLF 001', 'sis_section_id' => '2014-C-3623'}]
        end
        it 'filters out invalid section ids' do
          sis_section_ids = subject.official_section_identifiers
          expect(sis_section_ids).to be_an_instance_of Array
          expect(sis_section_ids.count).to eq 2
          expect(sis_section_ids[0]).to eq course_sections[0].merge({:term_yr=>'2014', :term_cd=>'C', :ccn=>'07309'})
          expect(sis_section_ids[1]).to eq course_sections[2].merge({:term_yr=>'2014', :term_cd=>'C', :ccn=>'06211'})
        end
      end

    end
  end

  context 'when creating new section within course' do
    it 'returns section details with id' do
      result = subject.create('Data Structures', '')
      expect(result).to be_an_instance_of Hash
      expect(result['id']).to eq 160
      expect(result['course_id']).to eq 5
      expect(result['name']).to eq 'Data Structures'
      expect(result['sis_course_id']).to eq "CRS:COMPSCI-61B-2014-D"
      expect(result['sis_section_id']).to eq nil
      expect(result['start_at']).to eq nil
      expect(result['end_at']).to eq nil
      expect(result['integration_id']).to eq nil
      expect(result['sis_import_id']).to eq nil
      expect(result['nonxlist_course_id']).to eq nil
    end
  end

end
