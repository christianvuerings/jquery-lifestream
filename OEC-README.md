# Online Evaluation of Courses (OEC) Support tasks

## Configuration

* Settings.oec has the list of terms and departments to restrict the export.

* Make sure your campusdb points at production oracle (bspprod) and that you have access to it.

## Rake tasks

* `rake oec:courses`
    1. This will generate a courses-{timestamp}.csv in tmp/oec.
    2. Send that file to Daphne.
    3. Daphne will filter out unwanted courses and give you back the filtered CSV.
    4. Copy the filtered CSV to tmp/oec/courses.csv

* `rake oec:instructors`
    1. This will generate 2 new CSV files in tmp/oec: One for instructors, and one for instructors' relationships to courses, all based on the CCNs found in courses.csv from the previous step.

* `rake oec:students`
    1. This will generate 2 new CSV files in tmp/oec: One for students, and one for students' relationships to courses, all based on the CCNs found in courses.csv from the previous step.
