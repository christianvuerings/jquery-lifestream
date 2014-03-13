require "spec_helper"

describe 'User::UserData' do

  it "should report DB outage" do
    User::UserData.stub(:find_by_sql).and_raise(
        ActiveRecord::StatementInvalid,
        "Java::OrgPostgresqlUtil::PSQLException: Connection refused. Check that the hostname and port are correct and that the postmaster is accepting TCP/IP connections.: select 1"
    )
    is_ok = User::UserData.database_alive?
    is_ok.should be_false
  end

  it "should attempt to recover from DB outage when DB is available" do
    User::UserData.stub(:find_by_sql).and_raise(
        ActiveRecord::StatementInvalid,
        "ActiveRecord::JDBCError: This connection has been closed.: select 1"
    )
    User::UserData.connection.should_receive(:reconnect!)
    User::UserData.database_alive?
  end

end
