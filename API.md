## API Endpoints:

Projected endpoints:

* ``` /api/my/status ```
* ``` /api/my/course_sites ```
* ``` /api/my/group_sites ```
* ``` /api/my/up_next ```
* ``` /api/my/tasks ```

```
/api/my/status :
  is_logged_in: <boolean>
  preferred_name: <string if exists else "">
  uid: <string uid if logged in>
  widget_data: <object>
  has_google_access_token: <boolean>
  has_canvas_access_token: <boolean>
```

```
/api/my/course_sites :
  course_code: <string identifying the course in campus data>
  name: <string if exists else not included>
  id: <string used by Canvas or bSpace>
  emitter: "Canvas" or "bSpace"
```
