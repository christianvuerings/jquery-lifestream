describe Canvas::Admins do

  let(:default_account_admin) {'323487'}
  let(:sub_account_admin) {'321654'}
  let(:non_admin) {'300846'}

  describe '#admin_user?' do
    context 'when account id not specified' do
      it 'returns true if user is primary account admin' do
        result = subject.admin_user?(default_account_admin)
        expect(result).to eq true
      end

      it 'returns false if user is not a primary account admin' do
        result = subject.admin_user?(sub_account_admin)
        expect(result).to eq false
      end
    end

    context 'when account id specified' do
      subject { Canvas::Admins.new(account_id: '87483') }

      it 'returns true if user is admin for account specified' do
        result = subject.admin_user?(sub_account_admin)
        expect(result).to eq true
      end

      it 'returns false if user is not admin for account specified' do
        result = subject.admin_user?(non_admin)
        expect(result).to eq false
      end
    end

    describe 'caching behavior' do
      context 'default' do
        it 'caches the local admins list' do
          expect(Rails.cache).to receive(:write).once
          subject.admin_user?(default_account_admin)
        end
      end
      context 'uncached' do
        it 'caches nothing' do
          expect(Rails.cache).to receive(:write).never
          subject.admin_user?(default_account_admin, cache: false)
        end
      end
    end

    describe '#add_new_admin' do
      subject { Canvas::Admins.new(fake: true) }
      it 'skips already present admins' do
        expect(Rails.cache).to receive(:write).never
        expect(subject).to receive(:add_admin).never
        result = subject.add_new_admin(default_account_admin)
        expect(result[:added]).to be_falsey
      end
      it 'adds the admin if not present' do
        expect(subject).to receive(:add_admin).once.and_call_original
        result = subject.add_new_admin(non_admin)
        expect(result[:added]).to eq true
      end
    end

  end

end
