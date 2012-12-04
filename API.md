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
  has_canvas_access_token: <boolean>
  has_google_access_token: <boolean>
  preferred_name: <string if exists else "">
  uid: <string uid if logged in>
  widget_data: <object>
```

```
/api/my/classes :
  course_code: <string identifying the course in campus data>
  emitter: "Canvas" or "bSpace"
  id: <string used by Canvas or bSpace>
  name: <string if exists else not included>
```
