describe Bearfacts::Schedule do

  it_should_behave_like 'a student data proxy' do
    let!(:proxy_class) { Bearfacts::Schedule }
    let!(:feed_key) { 'studentClassSchedules' }
  end

end
