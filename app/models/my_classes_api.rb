class MyClassesApi
  include ActiveAttr::Model
  attr_accessor :name, :course_code, :id, :emitter

  def self.all(uid)
    my_classes = []
    if (Oauth2Data.access_granted?(uid, "canvas"))
      canvas_proxy = CanvasProxy.new(user_id: uid)
      canvas_courses = JSON.parse(canvas_proxy.courses.body)
      my_canvas_classes = canvas_courses.collect do |course|
        MyClassesApi.new(name: course["name"], course_code: course["course_code"], id: course["id"], emitter: "Canvas")
      end
      my_classes.concat(my_canvas_classes)
    end
    my_classes
  end

end
