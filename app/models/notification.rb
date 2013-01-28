class Notification < ActiveRecord::Base
  attr_accessible :uid, :data, :translator

  def data
    JSON.parse(read_attribute(:data))
  end

  def data=(obj)
    write_attribute(:data, obj.to_json.to_s)
  end

end
