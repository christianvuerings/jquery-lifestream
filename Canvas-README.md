#Canvas support

## Canvas maintenance Rake tasks

When on a Torquebox-enabled shared servers, be sure to `cd deploy` before running any Rake or Rails command.

* `RAILS_ENV=production bundle exec rake canvas:full_refresh`
    1. For every current term, request a Canvas report on its sections.
    2. Download the reports.
    3. Append each section's current student enrollments and official list of instructors to a term-specific "enrollments" CSV file.
    4. Create a "users" CSV file with the current official name and email address of everyone mentioned in the enrollments list.
    5. Upload the "users" CSV file to Canvas.
    6. Upload each term's "enrollments" CSV to Canvas as a batch update, replacing all the previously imported student and instructor assignments for the term.
* `RAILS_ENV=production bundle exec rake canvas:make_csv_files`

    A more conservative version of the above, which generates the CSV files in "tmp/canvas" and lets you check them before uploading them to Canvas.
* `RAILS_ENV=production bundle exec rake canvas:repair_sis_ids TERM_ID='TERM:2013-C'`

    Our current integration scheme links a Canvas Course Section's SIS ID to the ID of an official section in campus systems. E.g., a Canvas Section whose sis_id was `SEC:2013-C-7309` would draw enrollments and instructors from CCN 7309 Summer 2013. For imports to work, the section's Canvas Course must have _some_ SIS ID, but what it is doesn't matter (for now). This task is an administrative convenience so that we don't manually have to come up with Course SIS IDs.
    1. Request a Canvas report on the sections of the specified term.
    2. Download the report.
    3. For each Course which has an SIS-integrated Section, but which has no SIS ID (or an otherwise improper SIS ID), write a good SIS ID to the Course.

## Canvas maintenance shell scripts

* `script/refresh-canvas-enrollments.sh`
    1. Set RAILS_ENV to 'production'.
    2. `cd deploy`
    2. Run `rake canvas:full_refresh`.
