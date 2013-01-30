## API Endpoints:

Projected endpoints:

* ``` /api/my/classes ```
* ``` /api/my/groups ```
* ``` /api/my/up_next ```
* ``` /api/my/status ```
* ``` /api/my/tasks ```

```
/api/my/status :
  is_logged_in: <boolean>
  first_login_at: <datetime or nil when you have not logged in yet>
  has_canvas_access_token: <boolean>
  has_google_access_token: <boolean>
  preferred_name: <string if exists else "">
  uid: <string uid if logged in>
```

```
/api/my/classes :
  course_code: <string identifying the course in campus data>
  color_class: <string canvas-class or bspace-class>
  emitter: "Canvas" or "bSpace"
  id: <string used by Canvas or bSpace>
  name: <string if exists else not included>
  site_url: <string the URL for the class>
```
