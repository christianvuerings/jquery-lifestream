module SpecHelperModule
  #Wish i could suppress the two logging suppressors
  def suppress_rails_logging
    original_logger = Rails.logger
    begin
      Rails.logger = Logger.new("/dev/null")
      yield
    ensure
      Rails.logger = original_logger
    end
  end

  def stub_proxy(feed_method, stub_body)
    proxy = double()
    response = double()
    response.stub(:status).and_return(200)
    response.stub(:body).and_return(stub_body.to_json)
    proxy.stub(feed_method).and_return(response)
    proxy
  end

  def random_id
    rand(99999).to_s
  end

  def delete_files_if_exists(filepaths)
    filepaths.to_a.each do |filepath|
      File.delete(filepath) if File.exists?(filepath)
    end
  end

end
