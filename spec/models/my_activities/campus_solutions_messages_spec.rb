describe MyActivities::CampusSolutionsMessages do
  let(:user_id) { random_id }
  let(:activities) { [] }

  context 'with a fake pending messages feed' do
    before do
      allow(CampusSolutions::PendingMessages).to receive(:new).and_return(CampusSolutions::PendingMessages.new(fake: true))
    end
    subject { MyActivities::CampusSolutionsMessages.append!(user_id, activities) }
    it 'should be able to process activities from a fake pending messages feed' do
      p "subj = #{subject}"
    end
  end

end
