describe MediacastsController do

  # Test data has no entry with a single digit CCN. Using the ccn_sets below, we expect 'No Webcast data found' for
  # each single digit ccn.
  let(:law_2723) { {:dept_name => 'LAW', :catalog_id => '2723', :term_yr => '2008', :term_cd => 'D', :ccn_set => [1, 49688, 2]} }
  let(:chem_101) { {:dept_name => 'CHEM', :catalog_id => '101', :term_yr => '2014', :term_cd => 'B', :ccn_set => [1, 2, 3]} }
  let(:malay_100A) { {:dept_name => 'MALAY/I', :catalog_id => '100A', :term_yr => '2014', :term_cd => 'D', :ccn_set => [85006]} }

  before { session['user_id'] = rand(99999).to_s }

  describe 'when serving webcast recordings' do
    context 'when Webcast feature flag is false' do
      before { Settings.features.videos = false }
      after { Settings.features.videos = true }
      it 'should return no videos' do
        json = post_course law_2723
        expect(json[:videos]).to be_nil
      end
    end

    context 'fetching fake data' do
      before do
        expect(Settings.webcast_proxy).to receive(:fake).at_most(3).and_return(true)
      end

      context 'when no Webcast recordings found' do
        it 'should campus_db query results are empty' do
          term_yr = '2014'
          term_cd = 'D'
          dept_name = 'ECON'
          catalog_id = '101'
          CampusOracle::Queries.should_receive(:get_all_course_sections).with(term_yr, term_cd, dept_name, catalog_id).and_return []
          post :get_media, year: term_yr, term_code: term_cd, dept: dept_name, catalog_id: catalog_id
          expect(response.status).to eq 200
          json = JSON.parse response.body
          expect(json['media']['2014']['D']).to be_empty
        end

        it 'should pay attention to term code' do
          json = post_course chem_101
          expect(json['media']['2014']['B']).to be_empty
        end
      end

      context 'when Webcast recordings found' do
        before(:each) do
          courses_list = [
            {
              :classes=>[
                {
                  :sections=>[
                    { :ccn=>'85006', :section_number=>'201', :instruction_format=>'LEC' }
                  ]
                }
              ]
            }
          ]
          expect_any_instance_of(MyAcademics::Teaching).to receive(:courses_list_from_ccns).once.and_return courses_list
        end
        it 'should escape special characters in dept name' do
          json = post_course malay_100A
          # This course happens to have zero YouTube videos
          course = json['media']['2014']['D']['85006']
          expect(course['videos']).to be_empty
          expect(course['itunes']['audio']).to be_nil
          expect(course['itunes']['video']).to include '819827828'
        end
      end
    end
  end

  private

  def post_course(course)
    # :year/:term_code/:dept/:catalog_id
    term_yr = course[:term_yr]
    term_cd = course[:term_cd]
    dept_name = course[:dept_name]
    catalog_id = course[:catalog_id]
    # Add leading zero to CCN to verify proper handling
    query_results = []
    course[:ccn_set].each {|ccn| query_results << { 'course_cntl_num' => "0#{ccn}" }}
    CampusOracle::Queries.should_receive(:get_all_course_sections).with(term_yr, term_cd, dept_name, catalog_id).and_return query_results
    post :get_media, year: term_yr, term_code: term_cd, dept: dept_name, catalog_id: catalog_id
    expect(response.status).to eq 200
    JSON.parse response.body
  end

end
