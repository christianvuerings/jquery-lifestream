# Online Evaluation of Courses (OEC) Support tasks

## Configuration

* The "oec" section of ./config/settings.yml has the list of terms and departments to restrict the export. It can take multiple values.
* Make sure your campusdb points at production oracle (bspprod) and that you have access to it.

## Rake tasks

* `rake oec:course_evaluations`
    1. This will generate a course_evaluations-{timestamp}.csv in tmp/oec.
    2. Send that file to Daphne.
    3. Daphne will filter out unwanted courses and give you back the filtered CSV.
    4. Copy the filtered CSV to tmp/oec/course_evaluations.csv

* `rake oec:students`
    1. This will generate 2 new CSV files in tmp/oec: One for students, and one for students' relationships to courses, all based on the CCNs found in courses.csv from the previous step.

## Weekly Update

* Log in to prod-03 and become app_calcentral user

* Update code:
```
cd ~/oec-export
git pull
bundle install
```

* Generate courses file:
```
RAILS_ENV=production rake oec:course_evaluations
cp tmp/oec/course_evaluations-{timestamp}.csv tmp/oec/course_evaluations.csv
```

* Now securely transfer course_evaluations.csv and attach to JIRA
* Justin will modify course_evaluations.csv and attach updated file to JIRA
* Then overwrite tmp/oec/course_evaluations.csv with the version from Justin

* Generating student files
```
RAILS_ENV=production rake oec:students
cp tmp/oec/students-{timestamp}.csv tmp/oec/students.csv
cp tmp/oec/course_students-{timestamp}.csv tmp/oec/course_students.csv
```

## Technical Overview

The rake tasks are defined in ./lib/tasks/oec.rake. They call out to model classes that are subclasses of Oec::Export.
Calling the #export method generates a CSV file with the subclass's defined headers. The subclass uses #append_records
to fill in the data appropriate to it.

Queries to the Oracle database are all kept in Oec::Queries.

Unit tests that cover all Oec code are in ./specs/models/oec. The tests use the CSV files in ./fixtures/oec to build
up fake lists of CCNs and then verify that the output code matches the fixture CSV. If you add columns to the CSV files
make sure to add the columns to the fixture files too, or unit tests may begin to fail.
