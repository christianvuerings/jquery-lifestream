require "spec_helper"

describe 'User::Data' do

  it "should report DB outage" do
    User::Data.stub(:find_by_sql).and_raise(
        ActiveRecord::StatementInvalid,
        "Java::OrgPostgresqlUtil::PSQLException: Connection refused. Check that the hostname and port are correct and that the postmaster is accepting TCP/IP connections.: select 1"
    )
    is_ok = User::Data.database_alive?
    is_ok.should be_falsey
  end

  it "should attempt to recover from DB outage when DB is available" do
    User::Data.stub(:find_by_sql).and_raise(
        ActiveRecord::StatementInvalid,
        "ActiveRecord::JDBCError: This connection has been closed.: select 1"
    )
    User::Data.connection.should_receive(:reconnect!)
    User::Data.database_alive?
  end

end
