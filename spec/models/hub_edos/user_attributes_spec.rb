require 'spec_helper'

describe HubEdos::UserAttributes do

  let(:user_id) { '61889' }
  subject { HubEdos::UserAttributes.new(user_id: user_id).get }
  it 'should provide the converted person data structure' do
    p "Subj = #{subject.inspect}"
    expect(subject[:ldap_uid]).to eq '61889'
    expect(subject[:student_id]).to eq '11667051'
    expect(subject[:first_name]).to eq 'Oski'
    expect(subject[:last_name]).to eq 'Bear'
    expect(subject[:person_name]).to eq 'Oski Bear'
  end

end
