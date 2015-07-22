describe Canvas::Admins do

  describe '#admin_user?' do
    context 'when account id not specified' do
      it 'returns true if user is primary account admin' do
        result = subject.admin_user?('323487')
        expect(result).to eq true
      end

      it 'returns false if user is not a primary account admin' do
        result = subject.admin_user?('101567')
        expect(result).to eq false
      end
    end

    context 'when account id specified' do
      subject { Canvas::Admins.new(account_id: '87483') }

      it 'returns true if user is admin for account specified' do
        result = subject.admin_user?('321654')
        expect(result).to eq true
      end

      it 'returns false if user is not admin for account specified' do
        result = subject.admin_user?('101568')
        expect(result).to eq false
      end
    end
  end

end
