# encoding: UTF-8

describe MailingLists::SiteMailingList do
  let(:canvas_site_id) { '1121' }
  let(:fake_course_data) { Canvas::Course.new(canvas_course_id: canvas_site_id, fake: true).course }
  before { allow_any_instance_of(Canvas::Course).to receive(:course).and_return fake_course_data }
  before { allow_any_instance_of(Calmail::CheckNamespace).to receive(:name_available?).and_return(response: true) }

  let(:response) { JSON.parse list.to_json}

  context 'a newly initialized list' do
    let(:list) { described_class.new(canvas_site_id: canvas_site_id) }

    it 'is valid' do
      expect(response).not_to include 'errorMessages'
    end

    it 'returns Canvas site data' do
      expect(response['canvasSite']['canvasCourseId']).to eq fake_course_data['id'].to_s
      expect(response['canvasSite']['url']).to include fake_course_data['id'].to_s
      expect(response['canvasSite']['courseCode']).to eq fake_course_data['course_code']
      expect(response['canvasSite']['sisCourseId']).to eq fake_course_data['sis_course_id']
      expect(response['canvasSite']['name']).to eq fake_course_data['name']
    end

    it 'initializes as unregistered' do
      expect(response['mailingList']['state']).to eq 'unregistered'
      expect(response['mailingList']['domain']).to eq Settings.calmail_proxy.domain
      expect(response['mailingList']).not_to include('creationUrl')
      expect(response['mailingList']).not_to include('timeLastPopulated')
    end

    it 'returns error on attempt to populate before save' do
      list.populate
      expect(response['errorMessages']).to include("Mailing list \"#{list.list_name}\" must be created before being populated.")
      expect(response['mailingList']).not_to include('timeLastPopulated')
    end

    describe 'normalizing list names' do
      it 'normalizes caps and spaces' do
        fake_course_data['name'] = 'CHEM 1A LEC 003'
        expect(response['mailingList']['name']).to eq 'chem_1a_lec_003-fa13'
      end

      it 'normalizes punctuation' do
        fake_course_data['name'] = 'The "Wild"-"Wild" West?'
        expect(response['mailingList']['name']).to eq 'the_wild_wild_west-fa13'
      end

      it 'removes invalid leading and trailing characters' do
        fake_course_data['name'] = '{{design}}'
        expect(response['mailingList']['name']).to eq 'design-fa13'
      end

      it 'normalizes diacritics' do
        fake_course_data['name'] = 'Conversation intermédiaire'
        expect(response['mailingList']['name']).to eq 'conversation_intermediaire-fa13'
      end
    end

    context 'nonexistent Canvas site' do
      before { allow_any_instance_of(Canvas::Course).to receive(:course).and_return nil }

      it 'returns error data' do
        expect(response).not_to include :mailingList
        expect(response['errorMessages']).to include("No bCourses site with ID \"#{canvas_site_id}\" was found.")
      end
    end
  end

  context 'creating a list' do
    let(:create_list) { described_class.create(canvas_site_id: canvas_site_id) }
    let(:list) { create_list }

    it 'creates pending list with a valid name' do
      count = described_class.count
      create_list
      expect(described_class.count).to eq count+1
      expect(response['mailingList']['state']).to eq 'pending'
      expect(response['mailingList']['creationUrl']).to be_present
    end

    context 'invalid list name' do
      let(:create_list) { described_class.create(canvas_site_id: canvas_site_id, list_name: '$crooge McDuck and the 1%') }

      it 'does not create a list with an invalid name' do
        count = described_class.count
        create_list
        expect(described_class.count).to eq count
        expect(response['errorMessages']).to include('List name may contain only lowercase, numeric, underscore and hyphen characters.')
      end
    end

    context 'list name already exists in Calmail' do
      before { allow_any_instance_of(Calmail::CheckNamespace).to receive(:name_available?).and_return(response: false) }

      it 'reports error and does not create new record' do
        count = described_class.count
        create_list
        expect(described_class.count).to eq count
        expect(response['errorMessages']).to include("Mailing list name \"#{list.list_name}\" is already taken.")
      end
    end

    context 'list name already exists in database' do
      let(:list_name) { random_string(15) }
      let(:create_list) { described_class.create(canvas_site_id: canvas_site_id, list_name: list_name) }
      before { described_class.create(canvas_site_id: random_id, list_name: list_name)  }

      it 'does not create list and returns error' do
        count = described_class.count
        create_list
        expect(described_class.count).to eq count
        expect(response['errorMessages']).to include("List name \"#{list_name}\" has already been reserved.")
      end
    end

    context 'course id already exists in database' do
      before { described_class.create(canvas_site_id: canvas_site_id)  }

      it 'does not create new record and returns error' do
        count = described_class.count
        create_list
        expect(described_class.count).to eq count
        expect(response['errorMessages']).to include("Canvas site ID \"#{canvas_site_id}\" has already reserved a mailing list.")
      end
    end
  end

  context 'an existing list record' do
    before { described_class.create(canvas_site_id: canvas_site_id)  }
    let(:list) { described_class.find_by(canvas_site_id: canvas_site_id) }

    context 'error from Calmail' do
      before { allow_any_instance_of(Calmail::CheckNamespace).to receive(:name_available?).and_return(response: {statusCode: 503}) }

      it 'reports the error' do
        expect(response['errorMessages']).to include('There was an error connecting to Calmail.')
      end
    end

    context 'name does not exist in Calmail' do
      before { allow_any_instance_of(Calmail::CheckNamespace).to receive(:name_available?).and_return(response: true) }

      it 'reports state as pending' do
        expect(response['mailingList']['state']).to eq 'pending'
        expect(response['mailingList']['creationUrl']).to be_present
      end

      it 'returns error on attempt to populate' do
        list.populate
        expect(response['errorMessages']).to include("Mailing list \"#{list.list_name}\" must be created before being populated.")
        expect(response['mailingList']).not_to include('timeLastPopulated')
      end
    end

    context 'name exists in Calmail' do
      before { allow_any_instance_of(Calmail::CheckNamespace).to receive(:name_available?).and_return(response: false) }

      it 'reports state as created' do
        expect(response['mailingList']['state']).to eq 'created'
        expect(response['mailingList']['creationUrl']).not_to be_present
        expect(response['mailingList']).not_to include('timeLastPopulated')
      end

      context 'populating list' do
        let(:course_users) { Canvas::CourseUsers.new(canvas_course_id: canvas_site_id, fake: true) }
        let(:list_members) { Calmail::ListMembers.new(fake: true) }

        let(:fake_add_proxy) { Calmail::AddListMember.new(fake: true) }
        let(:fake_remove_proxy) { Calmail::RemoveListMember.new(fake: true) }

        let(:oliver) { {'login_id' => '12345', 'first_name' => 'Oliver', 'last_name' => 'Heyer', 'email_address' => 'oheyer@berkeley.edu'}  }
        let(:ray) { {'login_id' => '67890', 'first_name' => 'Ray', 'last_name' => 'Davis', 'email_address' => 'raydavis@berkeley.edu'}  }
        let(:paul) { {'login_id' => '65536', 'first_name' => 'Paul', 'last_name' => 'Kerschen', 'email_address' => 'kerschen@berkeley.edu'}  }

        before do
          allow(Canvas::CourseUsers).to receive(:new).and_return course_users
          allow(Calmail::ListMembers).to receive(:new).and_return list_members

          allow(Calmail::AddListMember).to receive(:new).and_return fake_add_proxy
          allow(Calmail::RemoveListMember).to receive(:new).and_return fake_remove_proxy

          expect(course_users).to receive(:course_users).exactly(1).times.and_return fake_site_users
          expect(CampusOracle::Queries).to receive(:get_basic_people_attributes).exactly(1).times.and_return fake_site_users
        end

        def expect_empty_population_results(list, action)
          expect(list.population_results[action][:total]).to eq 0
          expect(list.population_results[action][:success]).to eq 0
          expect(list.population_results[action][:failure]).to eq []
        end

        context 'no change in list membership' do
          let(:fake_site_users) { [oliver, ray, paul] }
          let(:fake_list_members) { {response: {addresses: ['kerschen@berkeley.edu', 'oheyer@berkeley.edu', 'raydavis@berkeley.edu']}} }

          before do
            expect(list_members).to receive(:list_members).exactly(1).times.and_return fake_list_members
          end

          it 'makes no requests' do
            expect(fake_add_proxy).not_to receive(:add_member)
            expect(fake_remove_proxy).not_to receive(:remove_member)
            list.populate
          end

          it 'returns time, no errors and empty results' do
            list.populate
            expect(response['mailingList']['timeLastPopulated']).to be_present
            expect(response).not_to include 'errorMessages'
            expect_empty_population_results(list, :add)
            expect_empty_population_results(list, :remove)
            expect(response['populationResults']['success']).to eq true
            expect(response['populationResults']['messages']).to eq []
          end
        end

        context 'populating an empty list' do
          let(:fake_site_users) { [oliver, ray, paul] }
          let(:fake_list_members) { {response: {addresses: []}} }

          it 'requests addition and reports success' do
            expect(list_members).to receive(:list_members).exactly(1).times.and_return fake_list_members
            expect(fake_add_proxy).to receive(:add_member).exactly(3).times.and_call_original
            expect(fake_remove_proxy).not_to receive(:remove_member)
            list.populate
            expect(list.population_results[:add][:success]).to eq 3
            expect_empty_population_results(list, :remove)
            expect(response['populationResults']['success']).to eq true
            expect(response['populationResults']['messages']).to eq ['3 new members were added.']
          end

          context 'proxy reporting failure' do
            before do
              expect(fake_add_proxy).to receive(:add_member).exactly(3).times.
               and_return({response: {added: false}}, {response: {added: true}}, {response: {added: true}})
            end

            context 'reported failure is a real failure' do
              before do
                expect(list_members).to receive(:list_members).exactly(2).times.and_return(
                  {response: {addresses: []}},
                  {response: {addresses: ['raydavis@berkeley.edu', 'kerschen@berkeley.edu']}}
                )
              end

              it 'reports failure' do
                list.populate
                expect(list.population_results[:add][:total]).to eq 3
                expect(list.population_results[:add][:success]).to eq 2
                expect(list.population_results[:add][:failure]).to eq ['oheyer@berkeley.edu']
                expect_empty_population_results(list, :remove)
                expect(list.populate_add_errors).to eq 1
                expect(response['populationResults']['success']).to eq false
                expect(response['populationResults']['messages']).to eq ['1 new member could not be added.']
              end
            end

            context 'reported failure is not a real failure' do
              before do
                expect(list_members).to receive(:list_members).exactly(2).times.and_return(
                  {response: {addresses: []}},
                  {response: {addresses: ['oheyer@berkeley.edu', 'raydavis@berkeley.edu', 'kerschen@berkeley.edu']}}
                )
              end

              it 'reports success' do
                list.populate
                expect(list.population_results[:add][:total]).to eq 3
                expect(list.population_results[:add][:success]).to eq 3
                expect(list.population_results[:add][:failure]).to eq []
                expect_empty_population_results(list, :remove)
                expect(list.populate_add_errors).to eq 0
                expect(response['populationResults']['success']).to eq true
                expect(response['populationResults']['messages']).to eq ['3 new members were added.']
              end
            end
          end
        end

        context 'new users in course site' do
          let(:fake_site_users) { [oliver, ray, paul] }
          let(:fake_list_members) { {response: {addresses: ['oheyer@berkeley.edu']}} }

          it 'requests addition of new users only' do
            expect(list_members).to receive(:list_members).exactly(1).times.and_return fake_list_members
            expect(fake_add_proxy).to receive(:add_member).
              exactly(1).times.with(list.list_name, 'raydavis@berkeley.edu', 'Ray Davis').and_call_original
            expect(fake_add_proxy).to receive(:add_member).
              exactly(1).times.with(list.list_name, 'kerschen@berkeley.edu', 'Paul Kerschen').and_call_original
            expect(fake_remove_proxy).not_to receive(:remove_member)
            list.populate
            expect(list.population_results[:add][:total]).to eq 2
            expect(list.population_results[:add][:success]).to eq 2
            expect(list.population_results[:add][:failure]).to eq []
            expect_empty_population_results(list, :remove)
            expect(response['populationResults']['success']).to eq true
            expect(response['populationResults']['messages']).to eq ['2 new members were added.']
          end
        end

        context 'users no longer in course site' do
          let(:fake_site_users) { [oliver, ray] }
          let(:fake_list_members) { {response: {addresses: ['kerschen@berkeley.edu', 'oheyer@berkeley.edu', 'raydavis@berkeley.edu']}} }

          it 'requests removal of departed users only' do
            expect(list_members).to receive(:list_members).exactly(1).times.and_return fake_list_members
            expect(fake_add_proxy).not_to receive(:add_member)
            expect(fake_remove_proxy).to receive(:remove_member).
              exactly(1).times.with(list.list_name, 'kerschen@berkeley.edu').and_call_original
            list.populate
            expect_empty_population_results(list, :add)
            expect(list.population_results[:remove][:total]).to eq 1
            expect(list.population_results[:remove][:success]).to eq 1
            expect(list.population_results[:remove][:failure]).to eq []
            expect(response['populationResults']['success']).to eq true
            expect(response['populationResults']['messages']).to eq ['1 former member was removed.']
          end
        end
      end
    end
  end

end
