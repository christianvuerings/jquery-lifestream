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
    expect(subject[:ug_grad_flag]).to eq 'U'
    expect(subject[:affiliations]).to be
    expect(subject[:email_address]).to eq 'oski@berkeley.edu'
    expect(subject[:official_bmail_address]).to eq 'oski@berkeley.edu'
    expect(subject[:education_level]).to eq 'Sophomore'
    expect(subject[:tot_enroll_unit]).to eq 10
    expect(subject[:cal_residency_flag]).to eq 'Y'
    expect(subject[:education_abroad]).to be_truthy



  end

end
