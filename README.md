#CalCentral

[![Dependency Status](https://img.shields.io/gemnasium/ets-berkeley-edu/calcentral.svg)](https://gemnasium.com/ets-berkeley-edu/calcentral) [![devDependency Status](https://david-dm.org/ets-berkeley-edu/calcentral/dev-status.svg)](https://david-dm.org/ets-berkeley-edu/calcentral#info=devDependencies) [![Code Climate](https://img.shields.io/codeclimate/github/ets-berkeley-edu/calcentral.svg)](https://codeclimate.com/github/ets-berkeley-edu/calcentral)
* Master Build: [![Build Status](https://api.travis-ci.org/ets-berkeley-edu/calcentral.svg?branch=master)](https://travis-ci.org/ets-berkeley-edu/calcentral)
* QA Build: [![Build Status](https://api.travis-ci.org/ets-berkeley-edu/calcentral.svg?branch=qa)](https://travis-ci.org/ets-berkeley-edu/calcentral)

## Dependencies

* [Bundler](http://gembundler.com/rails3.html)
* [Git](https://help.github.com/articles/set-up-git)
* [JDBC Oracle driver](http://www.oracle.com/technetwork/database/enterprise-edition/jdbc-112010-090769.html)
* [Java 7 SDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
* [JRuby 1.7.x](http://jruby.org/)
* [Node.js >=0.10.30](http://nodejs.org/)
* [PostgreSQL](http://www.postgresql.org/)
* [Rails 3.2.x](http://rubyonrails.org/download)
* [Rubygems](http://rubyforge.org/frs/?group_id=126)
* [Rvm](https://rvm.io/rvm/install/) - Ruby version managers
* [xvfb](http://xquartz.macosforge.org/landing/) - xvfb headless browser, included for Macs with XQuartz

## Installation

1. Install Java 7 JDK:
http://www.oracle.com/technetwork/java/javase/downloads/index.html

1. Install postgres:

    **Note**: To install postgres, you must first install homebrew.

    Install homebrew with the following command:
    ```bash
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    ```
    Run the following command in terminal after installation:
    ```bash
    brew --version
    ```

    Then run the following:
    ```bash
    brew update
    brew install postgresql
    initdb /usr/local/var/postgres
    ```

    1. __For Mountain Lion & Mavericks users ONLY:__  [Fix Postgres paths](http://nextmarvel.net/blog/2011/09/brew-install-postgresql-on-os-x-lion/).

    1. __For Mountain Lion & Mavericks users ONLY:__ If you can connect to Postgres via psql, but not via JDBC (you see "Connection refused" errors in the CalCentral app log), then edit `/usr/local/var/postgres/pg_hba.conf` and make sure you have these lines:

        ```
        host    all             all             127.0.0.1/32            md5
        host    all             all             samehost                md5
        ```

    1. __For Mountain Lion & Mavericks users ONLY:__ [Install XQuartz](http://xquartz.macosforge.org/landing/) and make sure that /opt/X11/bin is on your `PATH`.

1. Start postgres, add users and create the necessary databases. (If your PostgreSQL server is managed externally, you'll probably need to create a schema that matches the database username. See [CLC-893](https://jira.media.berkeley.edu/jira/browse/CLC-893) for details.):

    ```bash
    pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
    psql postgres
    create database calcentral_development;
    create user calcentral_development with password 'secret' createdb;
    grant all privileges on database calcentral_development to calcentral_development;
    alter database calcentral_development owner to calcentral_development;
    create database calcentral;
    create user calcentral with password 'secret' createdb;
    grant all privileges on database calcentral to calcentral;
    alter database calcentral owner to calcentral;
    create database calcentral_test;
    create user calcentral_test with password 'secret' createdb;
    grant all privileges on database calcentral_test to calcentral_test;
    alter database calcentral_test owner to calcentral_test;
    ```

    **Note**: At this point, exit out of postgres. To do this, type "\q" and then press ENTER.

1. Fork this repository, then:

    ```bash
    git clone git@github.com:[your GitHub Account]/calcentral.git
    # e.g. git clone git@github.com:christianv/calcentral.git
    ```

1. Go inside the `calcentral` repository:

    ```bash
    cd calcentral
    # Answer "yes" if it asks you to trust a new .rvmrc file.
    ```

1. Install JRuby:

    ```bash
    rvm get head
    rvm install jruby-1.7.19
    cd ..
    cd calcentral
    # Answer "yes" again if it asks you to trust a new .rvmrc file.
    rvm list
    # Make sure that everything looks fine
    # If it mentions "broken", you'll need to reinstall
    ```

1. Make JRuby faster for local development by running this or put in your .bashrc:

    ``` bash
    export JRUBY_OPTS="--dev"
    ```

1. Download and install xvfb. On a Mac, you get xvfb by [installing XQuartz](http://xquartz.macosforge.org/landing/).

1. Download the appropriate gems with [Bundler](http://gembundler.com/rails3.html):

    ```bash
    bundle install
    ```

1. Set up a local settings directory:

    ```bash
    mkdir ~/.calcentral_config
    ```

    Default settings are loaded from your source code in `config/settings.yml` and `config/settings/ENVIRONMENT_NAME.yml`. For example, the configuration used when running tests with `RAILS_ENV=test` is determined by the combination of `config/settings/test.yml` and `config/settings.yml`.
    Because we don't store passwords and other sensitive data in source code, any RAILS_ENV other than `test` requires overriding some default settings.
    Do this by creating `ENVIRONMENT.local.yml` files in your `~/.calcentral_config` directory. For example, your `~/.calcentral_config/development.local.yml` file may include access tokens and URLs for a locally running Canvas server.
    You can also create Ruby configuration files like "settings.local.rb" and "development.local.rb" to amend the standard `config/environments/*.rb` files.

1. Install JDBC driver (for Oracle connection)
  * Download [ojdbc6.jar](http://svn.media.berkeley.edu/nexus/content/repositories/myberkeley/com/oracle/ojdbc6/11.2.0.3/ojdbc6-11.2.0.3.jar)
  * Note: You do not have to open the file.
  * Rename the file to `ojdbc6.jar`
  * Copy `ojdbc6.jar` to `calcentral/lib`

1. Initialize PostgreSQL database tables:

    ```bash
    rake db:schema:load db:seed
    ```

1. Make yourself powerful:

    ```bash
    rake superuser:create UID=[your numeric CalNet UID]
    # e.g. rake superuser:create UID=61889
    ```

1. Install the frond-end tools

    ```bash
    npm install
    npm install -g gulp
    ```

1. Start the front-end build & watch for changes

    ```bash
    gulp build
    ```

1. Start the server:

    ```bash
    rails s
    ```

1. Access your development server at [localhost:3000](http://localhost:3000/).
Do not use 127.0.0.1:3000, as you will not be able to grant access to bApps.

**Note**: Usually you won't have to do any of the following steps when you're developing on CalCentral.

## Enable live updates

In order to have live updates you'll need to perform the following steps:

1. Install and run [memcached](http://memcached.org/).

1. Add the following lines to development.local.yml:

  ```yml
  cache:
    store: "memcached"
  ```

1. Start the server with TorqueBox (see below).

## Back-end Testing

Back-end (rspec) tests live in `spec/*`.

To run the tests from the command line:

```bash
rspec
```

To run the tests faster, use spork, which is a little server that keeps the Rails app initialized while you change code
and run multiple tests against it. Command line:

```bash
spork
# (...wait a minute for startup...)
rspec --drb spec/lib/my_spec.rb
```

You can even run Spork right inside [IntelliJ RubyMine or IDEA](http://www.jetbrains.com/ruby/webhelp/using-drb-server.html).

## Front-end Linting

Front-end linting can be done by running the following commands:

```bash
rm -rf node_modules
npm install -g jshint
npm install -g jscs
gulp build
jshint .
jscs .
```

This will check for any potential JavaScript issues and whether you formatted the code correctly.

## Role-Aware Testing

Some features of CalCentral are only accessible to users with particular roles, such as `student`.
These features may be invisible when logged in as yourself. In particular:

- My Academics will only appear in the navigation if logged in as a student. However, the "Oski Bear" test student does not fake data loaded on dev and QA. To test My Academics, log in as user  `test-212385` or `test-212381` (ask a developer for the passwords to these if you need them). Once logged in as a test student, append `/academics` to the URL to access My Academics.

## Debugging

### Emulating production mode locally

1. Make sure you have a separate production database:

    ```bash
    psql postgres
    create database calcentral_production;
    grant all privileges on database calcentral_production to calcentral_development;
    ```

1. In calcentral_config/production.local.yml, you'll need the following entries:

    ```yml
    secret_token: "Some random 30-char string"
    postgres: [credentials for your separate production db (copy/modify from development.local.yml)]
    campusdb: [copy from main config/settings.yml, modify if needed]
    google_proxy: and canvas_proxy: [copy from development.local.yml]
      application:
        serve_static_assets: true
    ```

1. Populate the production db by invoking your production settings:

    ```bash
    RAILS_ENV="production" rake db:schema:load db:seed
    ```

1. Precompile the front-end assets

    ```bash
    gulp build --env production
    ```

1. Start the server in production mode:

    ```bash
    rails s -e production
    ```

1. If you're not able to connect to Google or Canvas, export the data in the oauth2 from your development db and import them into the same table in your production db.

1. After testing, remove the static assets:

    ```bash
    gulp build-clean
    ```

### Start the server with TorqueBox

In production we use [TorqueBox](http://torquebox.org/) as this provides us with messaging, scheduling, caching, and daemons.

1. Deploy into TorqueBox (only needs to happen once in a while):

    ```bash
    bundle exec torquebox deploy .
    ```

1. Start the server:

    ```bash
    bundle exec torquebox run -p=3000
    ```

### Test connection

Make sure you are on the Berkeley network or connected through [preconfigured VPN](https://kb.berkeley.edu/page.php?id=23065) for the Oracle connection.
If you use VPN, use group `1-Campus_VPN`.

### Enable basic authentication

Basic authentication will enable you to log in without using CAS.
This is necessary when your application can't be CAS authenticated or when you're testing mobile browsers.
**Note**: only enable this in fake mode or in development.

1. Add the following setting to your `environment.yml` file (e.g. `development.yml`):

    ```bash
    developer_auth:
      enabled: true
      password: topsecret!
    ```

1. (re)start the server for the changes to take effect.

1. Click on the footer (Berkeley logo) when you load the page.

1. You should be seeing the [Basic Auth screen](http://cl.ly/SA6C). As the login you should use a UID (e.g. `61889` for oski) and then the password from the settings file.

### "Act As" another user

To help another user debug an issue, you can "become" them on CalCentral. To assume the identity of another user, you must:

- Currently be logged in as a designated superuser
- Be accessing a machine/server which the other user has previously logged into (e.g. from localhost, you can't act as a random student, since that student has probably never logged in at your terminal)

Access the URL:

```
https://[hostname]/act_as?uid=123456
```

where 123456 is the UID of the user to emulate.

**Note**: The Act As feature will only reveal data from data sources we control, e.g. Canvas. Google data will be completely suppressed, __EXCEPT__ for test users. The following user uids have been configured as test users.
* 11002820 - "Tammi Chang"
* 61889 - "Oski Bear"
* All IDs listed on the [Universal Calnet Test IDs](https://wikihub.berkeley.edu/display/calnet/Universal+Test+IDs) page

To become yourself again, access:

```
https://[hostname]/stop_act_as
```

### Logging

Logging behavior and destination can be controlled from the command line or shell scripts via env variables:

* `LOGGER_STDOUT=false` - Only log to the default files
* `LOGGER_STDOUT=true` - Log to standard output as well as the default files
* `LOGGER_STDOUT=only` - Only log to standard output
* `LOGGER_LEVEL=DEBUG` - Set logging level; acceptable values are 'FATAL', 'ERROR', 'WARN', 'INFO', and 'DEBUG'

### Tips

1. On Mac OS X, to get RubyMine to pick up the necessary environment variables, open a new shell, set the environment variables, and:

    ```bash
    /Applications/RubyMine.app/Contents/MacOS/rubymine &
    ```

1. If you want to explore the Oracle database on Mac OS X, use [SQL Developer](http://www.oracle.com/technetwork/developer-tools/sql-developer/overview/index.html).

### Styleguide

See [docs/styleguide.md](docs/styleguide.md).

## Recording fake data feeds and timeshifting them

Make sure your testext.local.yml file has real connections to real external services that are fakeable (Canvas, Google, etc). Now do:

```bash
rake vcr:record
rake vcr:prettify
```

* `vcr:record` can also take a `SPEC=".../my_favorite_spec.rb"` to help limit the recordings.
* `vcr:prettify` can also take a `REGEX_FILTER="my_raw_recording.json"` to target a specific raw file.

You can now find the prettified files in `fixtures/pretty_vcr_recordings`. You can edit these files to put in tokens that will be substituted on server startup. See `config/initializers/timeshift.rb` for the dictionary of substitutions. Edit the `debug_json` property of each response, and `timeshift.rb` will automatically convert `debug_json` to the format actually used by VCR.

## Rake tasks:

To view other rake task for the project: `rake -T`

* `rake spec:xml` - Runs rake spec, but pipes the output to xml using the `rspec_junit_formatter` gem, for JUnit compatible test result reports
* `rake vcr:record` - Refresh vcr recordings and reformats the fixtures with formatted JSON output. Will also parse the reponse body's string into json output for legibility.
* `rake vcr:list` - List the available recordings captured in the fixtures.

## Memcached tasks:

A few rake tasks to help monitor statistics and more:

* `rake memcached:clear_stats` - Reset memcached stats from all cluster nodes.
* `rake memcached:empty` - Invalidate all memcached keys from all cluster nodes.
* `rake memcached:get_stats` - Fetch memcached stats from all cluster nodes.


* Generally, if you `rake memcached:empty` (__WARNING:__ do not run on the production cluster unless you know what you're doing), you should follow with an `rake memcached:clear_stats`.
* All three task take the optional param of `hosts`. So, if say you weren't running these tasks on the cluster layers themselves, or only wanted to tinker with a certain subset of clusters: `rake memcached:get_stats hosts="localhost:11212,localhost:11213,localhost:11214"`

## Using the feature toggle:

To selectively enable/disable a feature, add a property to the `features` section of settings.yml, e.g.:

```yml
features:
  wizbang: false
  neato: true
```

After server restart, these properties will appear in each users' status feed. You can now use `data-ng-if` in Angular to wrap the feature:

```html
<div data-ng-if="user.profile.features.neato">
  Some neato feature...
</div>
```

## Keeping developer seed data updated

`seeds.rb` is intended for use only on developer machines, so they have a semi-realistic copy of production lists of
superusers, links, etc. `./db/developer-seed-data.sql` has the data used by `rake db:seed`. Occasionally we'll want to
update it from production. To do that, log into a prod node and do:

```bash
pg_dump calcentral -O -x --inserts --clean -f developer-seed-data.sql -t link_categories \
-t link_categories_link_sections -t link_sections -t link_sections_links -t links \
-t links_user_roles -t user_auths -t user_roles -t fin_aid_years -t summer_sub_terms \
-h postgres-hostname -p postgres-port-number -U calcentral
```

Copy the file into your source tree and get it merged into master.
