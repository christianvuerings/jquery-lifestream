require "spec_helper"

describe CanvasLtiController do

  let(:lti_values) {{
    'canvas_user_login_id' => random_id,
    'canvas_user_id' => random_id,
    'canvas_course_id' => random_id
  }}
  let(:lti) do
    obj = double
    allow(obj).to receive(:get_custom_param) do |key|
      lti_values[key]
    end
    obj
  end

  shared_examples 'an LTI authentication' do
    it 'embeds all session variables' do
      expect(session[:user_id]).to eq lti_values['canvas_user_login_id']
      expect(session[:canvas_user_id]).to eq lti_values['canvas_user_id']
      expect(session[:canvas_course_id]).to eq lti_values['canvas_course_id']
    end
  end

  describe 'authenticate_by_lti' do
    context 'when the user is not logged into CalCentral' do
      before do
        subject.send(:authenticate_by_lti, lti)
      end
      it_behaves_like 'an LTI authentication'
      it 'notes that the authentication is valid only for LTI' do
        expect(session[:lti_authenticated_only]).to be_true
      end
    end
    context 'when the user is already logged into CalCentral' do
      before do
        session[:user_id] = lti_values['canvas_user_login_id']
        subject.send(:authenticate_by_lti, lti)
      end
      it_behaves_like 'an LTI authentication'
      it 'does not flag the authentication' do
        expect(session[:lti_authenticated_only]).to be_false
      end
    end
    context 'when the user does not match an existing CalCentral login' do
      before do
        session[:user_id] = random_id
        session[:some_random_junk] = random_id
        subject.send(:authenticate_by_lti, lti)
      end
      it_behaves_like 'an LTI authentication'
      it 'wipes the session first' do
        expect(session[:some_random_junk]).to be_nil
        expect(session[:lti_authenticated_only]).to be_true
      end
    end
  end

end
