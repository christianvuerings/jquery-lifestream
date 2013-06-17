## API Endpoints:

Projected endpoints:

* ``` /api/my/classes ```
* ``` /api/my/groups ```
* ``` /api/my/up_next ```
* ``` /api/my/status ```
* ``` /api/my/tasks ```

```
/api/my/status :
  features: {
    notifications: <boolean>,
    act_as: <boolean>
  },
  first_login_at: <datetime or nil when you have not logged in yet>
  first_name: <string if exists else "">
  has_canvas_account: <boolean>
  has_google_access_token: <boolean>
  is_logged_in: <boolean>
  last_name: <string if exists else "">
  preferred_name: <string if exists else "">
  roles: {
    student: <boolean>,
    faculty: <boolean>,
    staff: <boolean>
  },
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
