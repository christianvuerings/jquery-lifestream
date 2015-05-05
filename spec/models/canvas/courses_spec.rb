describe Canvas::Courses do

  let(:response) {
    Response = Class.new do
      def body
        <<-eos
        [
          {
              "account_id": 102802,
              "course_code": "FRENCH 1",
              "id": 787856,
              "name": "Elementary French"
          },
          {
              "account_id": 129082,
              "course_code": "EE 20N",
              "id": 833382,
              "name": "Structure and Interpretation of Systems and Signals"
          }
        ]
        eos
      end
    end.new
  }

  context 'fake data' do
    subject { Canvas::Courses.new({:user_id => @user_id}).official_courses }

    it 'should return official courses per configured account_id' do
      allow_any_instance_of(Canvas::Proxy).to receive(:request_uncached).and_return response
      expect(subject).to have_at_least(1).items
      expect(subject[0]['id']).to eq 787856
    end

    it 'should return nil when nil response' do
      allow_any_instance_of(Canvas::Proxy).to receive(:request_uncached).and_return nil
      expect(subject).to be_nil
    end
  end

end
