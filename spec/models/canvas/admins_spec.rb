describe Canvas::Admins do
  let(:sub_account_id)      { '87483' }
  let(:admin_uid)           { '321654' }
  let(:response_json)       { "[{\"id\": 12345, \"role\": \"AccountAdmin\", \"user\": { \"id\": 3218765, \"name\": \"Purple Hays\", \"sortable_name\": \"Hays, Purple\", \"short_name\": \"Purple Hays\", \"sis_user_id\": \"UID:#{admin_uid}\", \"sis_login_id\": \"#{admin_uid}\", \"login_id\": \"#{admin_uid}\"}}]" }
  let(:current_page_link)   { "<https://example.instructure.com/api/v1/accounts/#{sub_account_id}/admins?page=2&per_page=30>; rel=\"current\"" }
  let(:prev_page_link)      { "<https://example.instructure.com/api/v1/accounts/87483/admins?page=1&per_page=30>; rel=\"prev\"" }
  let(:first_page_link)     { "<https://example.instructure.com/api/v1/accounts/87483/admins?page=1&per_page=30>; rel=\"first\"" }
  let(:last_page_link)      { "<https://example.instructure.com/api/v1/accounts/87483/admins?page=2&per_page=30>; rel=\"last\"" }
  let(:response_links)      { [current_page_link, prev_page_link, first_page_link, last_page_link].join(',') }
  let(:admins_response) do
    response = double
    response.stub(:status).and_return(200)
    response.stub(:[]).with("link").and_return(response_links)
    response.stub(:body).and_return(response_json)
    response
  end

  describe "#admin_user?" do
    context "when account id not specified" do
      it "returns true if user is primary account admin" do
        result = subject.admin_user?('323487')
        expect(result).to eq true
      end

      it "returns false if user is not a primary account admin" do
        result = subject.admin_user?('101567')
        expect(result).to eq false
      end
    end

    context "when account id specified" do
      subject { Canvas::Admins.new(:account_id => sub_account_id) }
      before  { subject.should_receive(:request_uncached).with("accounts/#{sub_account_id}/admins?per_page=100").and_return(admins_response) }

      it "returns true if user is admin for account specified" do
        result = subject.admin_user?(admin_uid)
        expect(result).to eq true
      end

      it "returns false if user is not admin for account specified" do
        result = subject.admin_user?('101568')
        expect(result).to eq false
      end
    end
  end

end
