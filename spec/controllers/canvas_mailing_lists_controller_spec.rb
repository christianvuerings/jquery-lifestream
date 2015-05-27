describe CanvasMailingListsController do
  let(:course_id) { rand(999999).to_s }
  let(:uid) { rand(999999).to_s }

  before do
    session['user_id'] = uid
    allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_administrate_canvas?).and_return(true)
  end

  shared_examples 'authorization and error handling' do
    it_should_behave_like 'an api endpoint' do
      before do
        allow(MailingLists::SiteMailingList).to receive(:find_by).and_raise(RuntimeError, 'Something went wrong')
        allow_any_instance_of(MailingLists::SiteMailingList).to receive(:initialize).and_raise(RuntimeError, 'Something went wrong')
      end
    end

    it_should_behave_like 'a user authenticated api endpoint'

    context 'when user is not authorized' do
      before { allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_administrate_canvas?).and_return(false) }
      it 'should respond with empty http 403' do
        make_request
        expect(response.status).to eq 403
        expect(response.body).to eq ' '
      end
    end
  end

  def fake_mailing_list(filename)
    JSON.parse(File.read Rails.root.join('public', 'dummy', 'json', filename))
  end

  describe '#show' do
    let(:make_request) { get :show, canvas_course_id: course_id }
    include_examples 'authorization and error handling'

    it 'returns a fake unregistered mailing list' do
      allow(MailingLists::SiteMailingList).to receive(:find_or_initialize_by).and_return fake_mailing_list('canvas_site_mailing_list_new.json')

      make_request
      expect(response.status).to eq 200
      expect(response.body).to include '"state":"unregistered"'
    end
  end

  describe '#create' do
    let(:make_request) { post :create, canvas_course_id: course_id, list_name: 'digression_analysis-sp15' }
    include_examples 'authorization and error handling'

    it 'returns a fake pending mailing list' do
      allow(MailingLists::SiteMailingList).to receive(:create).and_return fake_mailing_list('canvas_site_mailing_list_pending.json')

      make_request
      expect(response.status).to eq 200
      expect(response.body).to include '"state":"pending"'
    end
  end

  describe '#populate' do
    let(:make_request) { post :populate, canvas_course_id: course_id  }
    include_examples 'authorization and error handling'

    it 'returns a fake mailing list with time last populated' do
      fake_created_list = fake_mailing_list('canvas_site_mailing_list_populated_success.json')
      allow(MailingLists::SiteMailingList).to receive(:find_by).and_return fake_created_list
      allow(fake_created_list).to receive(:populate)

      make_request
      expect(response.status).to eq 200
      expect(response.body).to include '"state":"created"'
      expect(response.body).to include '"timeLastPopulated"'
    end
  end

  describe '#delete' do
    let(:make_request) { delete :destroy, canvas_course_id: course_id  }
    include_examples 'authorization and error handling'

    it 'returns a success response' do
      fake_list = instance_double('MailingLists::SiteMailingList')
      allow(MailingLists::SiteMailingList).to receive(:find_by).and_return fake_list
      allow(fake_list).to receive(:destroy).and_return true

      make_request
      expect(response.status).to eq 200
      expect(response.body).to include '"success":true'
    end
  end

end
