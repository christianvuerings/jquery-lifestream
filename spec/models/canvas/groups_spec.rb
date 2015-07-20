describe Canvas::Groups do

  subject { Canvas::Groups.new(user_id: @user_id) }
  let(:response) { subject.groups }

  it 'should get groups as known member' do
    expect(response[:body]).to_not be_empty
    expect(response[:body][0]['name']).to be_present
  end

  context 'on request failure' do
    let(:failing_request) { {method: :get} }
    it_should_behave_like 'a paged Canvas proxy handling request failure'
  end

end
