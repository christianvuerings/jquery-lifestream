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
end