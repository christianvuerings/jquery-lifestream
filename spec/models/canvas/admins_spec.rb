require "spec_helper"

describe Canvas::Admins do
  let(:global_account_id)   { '90242' }
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

  describe "#admins_list" do
    context "when account id not specified" do
      it "provides admins list" do
        result = subject.admins_list
        expect(result).to be_an_instance_of Array
        expect(result.count).to eq 3
        result.each do |admin|
          expect(admin).to be_an_instance_of Hash
          expect(admin['id']).to be_an_instance_of Fixnum
          expect(admin['role']).to be_an_instance_of String
          expect(admin['user']).to be_an_instance_of Hash
        end
      end

      it "makes request to primary account" do
        subject.should_receive(:request_uncached).with("accounts/#{global_account_id}/admins?per_page=30", "_admins").and_return(admins_response)
        result = subject.admins_list
      end
    end

    context "when account id specified" do
      subject { Canvas::Admins.new(:account_id => sub_account_id) }
      it "makes request to account id specified" do
        subject.should_receive(:request_uncached).with("accounts/#{sub_account_id}/admins?per_page=30", "_admins").and_return(admins_response)
        result = subject.admins_list(:cache => false)
      end

      it "provides sub-account admins list" do
        subject.should_receive(:request_uncached).with("accounts/#{sub_account_id}/admins?per_page=30", "_admins").and_return(admins_response)
        result = subject.admins_list(:cache => false)
        expect(result).to be_an_instance_of Array
        expect(result.count).to eq 1
        expect(result[0]['user']['name']).to eq "Purple Hays"
      end
    end
  end

  describe "#admin_user?" do
    context "when account id not specified" do
      it "returns true if user is primary account admin" do
        result = subject.admin_user?('323487', false)
        expect(result).to eq true
      end

      it "returns false if user is not a primary account admin" do
        result = subject.admin_user?('101567', false)
        expect(result).to eq false
      end
    end

    context "when account id specified" do
      subject { Canvas::Admins.new(:account_id => sub_account_id) }
      before  { subject.should_receive(:request_uncached).with("accounts/#{sub_account_id}/admins?per_page=30", "_admins").and_return(admins_response) }

      it "returns true if user is admin for account specified" do
        result = subject.admin_user?(admin_uid, false)
        expect(result).to eq true
      end

      it "returns false if user is not admin for account specified" do
        result = subject.admin_user?('101568', false)
        expect(result).to eq false
      end
    end
  end

end
