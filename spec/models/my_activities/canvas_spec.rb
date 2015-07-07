describe MyActivities::CanvasActivities do
  let!(:documented_types) { %w(alert announcement assignment discussion gradePosting message webconference) }

  let(:activities) { MyActivities::CanvasActivities.get_feed(@user_id, indexed_classes) }
  let(:indexed_classes) { MyActivities::CanvasActivities.index_classes_by_emitter(classes) }

  before do
    @user_id = Settings.canvas_proxy.test_user_id
    @fake_activity_stream_proxy = Canvas::UserActivityStream.new({fake: true})
    @fake_activity_stream = JSON.parse(@fake_activity_stream_proxy.user_activity.body)
    @fake_time = Time.zone.today.in_time_zone.to_datetime
  end

  context 'when classes feed is empty' do
    let(:classes) { [] }

    it 'should be able to process a normal canvas feed' do
      activities.each do |activity|
        expect(activity[:id]).to be_present
        expect(activity[:date][:epoch]).to be_a Integer
        expect(activity[:source]).to be_present
        expect(activity).to include({
          user_id: @user_id,
          emitter: Canvas::Proxy::APP_NAME
        })
        expect(documented_types).to include(activity[:type])
      end
    end

    it 'should be able to ignore malformed entries from the canvas feed' do
      bad_date_entry = { 'id' => @user_id, 'user_id' => @user_id, 'created_at' => 'stone-age'}
      flawed_activity_stream = @fake_activity_stream + [bad_date_entry]
      Canvas::UserActivityStream.stub(:new).and_return(stub_proxy(:user_activity, flawed_activity_stream))
      expect(activities.size).to eq @fake_activity_stream.size
    end

    context 'fake activity stream' do
      before { allow(Canvas::UserActivityStream).to receive(:new).and_return @fake_activity_stream_proxy }

      it 'should sometimes have score and instructor message appended to the summary field' do
        # Search for a particular entry in the cassette and make sure it's appended to properly
        activity = activities.select {|entry| entry[:id] == 'canvas_40544495'}.first
        expect(activity[:summary]).to eq 'Please write more neatly next time. 87 out of 100 - Good work!'
      end

      it 'should strip system generated "click here" URLs from the summary field' do
        activity = activities.select {|entry| entry[:id] == 'canvas_43225861'}.first
        expect(activity[:summary]).to eq 'First, some instructor-written text. Click here to view the assignment: https://ucberkeley.instructure.com/courses/832071/assignments/3043635 A new assignment has been created for your course, Biology for Poets Report to STC due: Apr 1 at 11:59pm'
      end

      it 'should not over-strip by removing instructor-added "click here" URLs' do
        activity = activities.select {|entry| entry[:id] == 'canvas_43395837'}.first
        expect(activity[:summary]).to eq 'First, some instructor-added text. You can view the submission here: http://example.com?p=123 Oski Bear has just turned in a late submission for Tibullus paper in the course Biology for Poets'
      end
    end
  end

  context 'when classes feed contains sites' do
    let(:classes) do
      [
        {
          id: '1',
          name: 'Site 1 name',
          shortDescription: 'Site 1 description',
          siteType: 'course',
          emitter: Canvas::Proxy::APP_NAME,
          courses: course_ids
        },
        {
          id: '2',
          source: 'Site 2 source',
          name: 'Site 2 name',
          siteType: 'group',
          emitter: Canvas::Proxy::APP_NAME
        },
        {
          id: '3',
          name: 'Group name 3',
          siteType: 'group',
          emitter: Canvas::Proxy::APP_NAME
        },
        {
          id: '4',
          source: 'Site 4 source',
          name: 'Site 4 name',
          siteType: 'group',
          emitter: Canvas::Proxy::APP_NAME,
          courses: course_ids
        },
      ].concat(campus_classes)
    end
    let(:canvas_feed) do
      [
        {
          id: 1999,
          context_type: 'Course',
          type: 'Message',
          course_id: 1,
          title: 'Assignment created',
          updated_at: @fake_time,
          created_at: @fake_time
        },
        {
          id: 2999,
          context_type: 'Group',
          type: 'Message',
          group_id: 2,
          title: 'Assignment deleted',
          updated_at: @fake_time,
          created_at: @fake_time
        },
        {
          id: 3999,
          context_type: 'Group',
          type: 'Message',
          group_id: 3,
          title: 'Party date',
          updated_at: @fake_time,
          created_at: @fake_time
        },
        {
          id: 4999,
          context_type: 'Group',
          type: 'Message',
          group_id: 4,
          title: 'Post-assignment party',
          updated_at: @fake_time,
          created_at: @fake_time
        },
        {
          id: 5999,
          type: 'Conversation',
          conversation_id: 5,
          title: nil,
          updated_at: @fake_time,
          created_at: @fake_time
        }
      ]
    end

    let(:course_ids) { nil }
    let(:campus_classes) { [] }

    before { allow(Canvas::UserActivityStream).to receive(:new).and_return stub_proxy(:user_activity, canvas_feed) }

    it 'should transform raw Canvas feed entries to activities' do
      expect(activities).to have(5).items
      activities.each do |activity|
        expect(activity).to include({
          user_id: @user_id,
          emitter: 'bCourses'
        })
        expect(activity[:type]).to be_present
      end
    end

    describe 'source property' do
      shared_examples 'activity source derived from course codes' do
        context 'with an associated campus course' do
          let(:course_ids) { [{id: 'anthro-3ac-2013-D'}] }
          let(:campus_classes) do
            [{
              emitter: 'Campus',
              listings: [{course_code: 'ANTHRO 3AC', id: 'anthro-3ac-2013-D'}]
            }]
          end
          it 'should select the campus course code' do
            expect(activity[:source]).to eq 'ANTHRO 3AC'
          end
        end
        context 'with multiple associated campus courses' do
          let(:course_ids) do
            [
              {id: 'anthro-3ac-2013-D'},
              {id: 'anthro-99-2013-D'},
            ]
          end
          let(:campus_classes) do
            [{
              emitter: 'Campus',
              listings: [{course_code: 'ANTHRO 3AC', id: 'anthro-3ac-2013-D'}]
            },
            {
              emitter: 'Campus',
              listings: [{course_code: 'ANTHRO 99', id: 'anthro-99-2013-D'}]
            }]
          end
          it 'should map to an array of campus course codes' do
            expect(activity[:source]).to contain_exactly('ANTHRO 3AC', 'ANTHRO 99')
          end
        end
      end

      context 'an activity from a course site' do
        let(:activity) { activities.select{|item| item[:id] == 'canvas_1999'}[0] }

        include_examples 'activity source derived from course codes'

        context 'with no associated campus course' do
          it 'should fall back on Canvas site name' do
            expect(activity[:source]).to eq 'Site 1 name'
          end
        end
      end

      context 'a group site with associated courses and a source property' do
        let(:activity) { activities.select{|item| item[:id] == 'canvas_4999'}[0] }
        include_examples 'activity source derived from course codes'
      end

      context 'a group site with a source property and no associated courses' do
        let(:activity) { activities.select{|item| item[:id] == 'canvas_2999'}[0] }
        it 'should preferentially select the source property' do
          expect(activity[:source]).to eq 'Site 2 source'
        end
      end

      context 'a group site with no source property or associated courses' do
        let(:activity) { activities.select{|item| item[:id] == 'canvas_3999'}[0] }
        it 'should fall back on the name property' do
          expect(activity[:source]).to eq 'Group name 3'
        end
      end

      context 'an activity with no site' do
        let(:activity) { activities.select{|item| item[:id] == 'canvas_5999'}[0] }
        it 'should fall back on emitter name' do
          expect(activity).to include({
            source: 'bCourses',
            title: 'New/Updated Conversation',
            type: 'discussion'
          })
        end
      end

    end
  end
end
