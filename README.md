#CalCentral

Home of CalCentral. [![Dependency Status](https://gemnasium.com/ets-berkeley-edu/calcentral.png)](https://gemnasium.com/ets-berkeley-edu/calcentral) [![Code Climate](https://codeclimate.com/github/ets-berkeley-edu/calcentral.png)](https://codeclimate.com/github/ets-berkeley-edu/calcentral)
* Master: [![Build Status](https://travis-ci.org/ets-berkeley-edu/calcentral.png?branch=master)](https://travis-ci.org/ets-berkeley-edu/calcentral)
* QA: [![Build Status](https://travis-ci.org/ets-berkeley-edu/calcentral.png?branch=qa)](https://travis-ci.org/ets-berkeley-edu/calcentral)

## Dependencies

* [Bundler](http://gembundler.com/rails3.html)
* [Git](https://help.github.com/articles/set-up-git)
* [JDBC Oracle driver](http://www.oracle.com/technetwork/database/enterprise-edition/jdbc-112010-090769.html)
* [JRuby 1.7.x](http://jruby.org/)
* [PostgreSQL](http://www.postgresql.org/)
* [Rails 3.2.x](http://rubyonrails.org/download)
* [Rubygems](http://rubyforge.org/frs/?group_id=126)
* [Rvm](https://rvm.io/rvm/install/) - Ruby version managers

## Installation

1. Install postgres
```bash
brew update
brew install postgresql
initdb /usr/local/var/postgres
```
__For Mountain Lion users ONLY:__ There's a few [extra steps](https://coderwall.com/p/1mni7w).


2. Start postgres, add the user and create the necessary databases
```bash
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
psql postgres
create database calcentral_development;
create user calcentral_development with password 'secret';
grant all privileges on database calcentral_development to calcentral_development;
create database calcentral;
create user calcentral with password 'secret';
grant all privileges on database calcentral to calcentral;
create database calcentral_test;
create user calcentral_test with password 'secret';
grant all privileges on database calcentral_test to calcentral_test;
```

(If your PostgreSQL server is managed externally, you'll probably need to create a schema that matches the database username. See CLC-893 for details.)

3. Fork this repository, then:
```bash
git clone git@github.com:[your_github_acct]/calcentral.git
```

4. Go inside the `calcentral` repository
```bash
cd calcentral
# Answer "yes" if it asks you to trust a new .rvmrc file.
```

5. Install jruby
```bash
rvm get head
rvm install jruby-1.7.3
cd ..
cd calcentral
# Answer "yes" again if it asks you to trust a new .rvmrc file.
```

6. (Optional for development) Make JRuby faster & enable C extensions by running this or put in your .bashrc:
```bash
export JRUBY_OPTS="-Xcext.enabled=true -J-d32 -J-client -X-C"
```
  * __WARNING__: Do not switch between 32-bit and 64-bit JRuby after your gemset has been initialized (your bundle library will have serious issues). If you do need to change settings, make sure to reinitialize your gemset:
     * ```rvm gemset delete calcentral```
     * (set your JRUBY_OPTS)
     * ```bundle install```

7. Download the appropriate gems with [Bundler](http://gembundler.com/rails3.html)
```bash
bundle install
```

8. Copy and update the settings
```
mkdir ~/.calcentral_config
cp config/settings.yml ~/.calcentral_config/settings.local.yml
cp config/settings/testext.yml ~/.calcentral_config/testext.local.yml
cp config/settings/development.yml ~/.calcentral_config/development.local.yml
cp config/settings/production.yml ~/.calcentral_config/production.local.yml
```
and update the settings in the `.local.yml` files.
Settings live outside of the project dir to prevent accidental commits to the repo.
You can also create Ruby configuration files like "settings.local.rb" and "development.local.rb" to amend the standard `config/environments/*.rb` files.

9. Install JDBC driver (for Oracle connection)
You may already have an Oracle driver from MyBerkeley-OAE development, in which case you just need to copy it to your project ./lib directory:
```cp ~/.m2/repository/com/oracle/ojdbc6/11.2.0.3/ojdbc6-11.2.0.3.jar ./lib/```
  * Otherwise, download [ojdbc6.jar](http://www.oracle.com/technetwork/database/enterprise-edition/jdbc-112010-090769.html)
  * Copy ojdbc6.jar to your project's lib folder```

10. Initialize PostgreSQL database tables
```bash
rake db:schema:load
```

11. Deploy into TorqueBox
```bash
bundle exec torquebox deploy .
```

12. Start the server
```bash
bundle exec torquebox run -p=3000
```

13. Access your development server at [localhost:3000](http://localhost:3000/).
Do not use 127.0.0.1:3000, as you will not be able to grant access to bApps.

## Front-end Testing

Front-end [jasmine](http://pivotal.github.com/jasmine/) tests live in spec/javascripts/calcentral/*.

To run the tests headless on firefox run `rake jasmine:ci`.

To view results of front-end tests, run `rake jasmine` in a separate terminal,
then visit [localhost:8888](http://localhost:8888).

## Role-Aware Testing

Some features of CalCentral are accessible only to users with particular roles, such as "student."
These features may be invisible when logged in as yourself. In particular:

- My Academics will only appear in the navigation if logged in as a student. However, the "Oski Bear" test student does not fake data loaded on dev and QA. To test My Academics, log in as user  test-212385 or test-212381 (ask a developer for the passwords to these if you need them). Once logged in as a test student, append "/academics" to the URL to access My Academics (this will change when CLC-1755 is resolved).

## Debugging

### Emulating production mode locally

1. Make sure you have a separate production database. In psql:
```
create database calcentral_production;
grant all privileges on database calcentral_production to calcentral_development;
```

2. In calcentral_config/production.local.yml, you'll need the following entries:
```
secret_token: "Some random 30-char string"
postgres: [credentials for your separate production db (copy/modify from development.local.yml)]
campusdb: [copy from main config/settings.yml, modify if needed]
google_proxy: and canvas_proxy: [copy from development.local.yml]
  application:
    serve_static_assets: true
```

3. Populate the production db by invoking your production settings:
```
rake db:schema:load RAILS_ENV="production"
```

4. Precompile the assets: [(more info)](http://stackoverflow.com/questions/7275636/rails-3-1-0-actionviewtemplateerrror-application-css-isnt-precompiled)
```bash
bundle exec rake assets:precompile
```

5. Start the server in production mode
```bash
rails s -e production
```

6. If you're not able to connect to Google or Canvas, export the data in the oauth2 from your development db and import them into the same table in your production db.

7. After testing, remove the static assets and generated pages
```bash
bundle exec rake assets:clean
```

### Test connection

Make sure you are on the Berkeley network or connected through [preconfigured VPN](https://kb.berkeley.edu/jivekb/entry.jspa?externalID=2665) for the Oracle connection.
If you use VPN, use group #1 (1-Campus_VPN)


### "Act As" another user

To help another user debug an issue, you can "become" them on CalCentral. To assume the identity of another user, you must:

- Currently be logged in as a designated superuser
- Be accessing a machine/server which the other user has previously logged into (e.g. from localhost, you can't act as a random student, since that student has probably never logged in at your terminal)
- Have enabled act_as in settings.yml (features:)

Access the URL:

```
https://[hostname]/act_as?uid=123456
```

where 123456 is the UID of the user to emulate.

n.b.: The Act As feature will only reveal data from data sources we control, e.g. Canvas. Google data will be completely suppressed, __EXCEPT__ for test users. The following user uids have been configured as test users.
* 11002820 - "Tammi Chang"
* 61889 - "Oski Bear"
* All IDs listed on the ["Universal Calnet Test IDs"](https://wikihub.berkeley.edu/display/calnet/Universal+Test+IDs) page

To become yourself again, access

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

2. If you want to explore the Oracle database on Mac OS X, use [SQL Developer](http://www.oracle.com/technetwork/developer-tools/sql-developer/overview/index.html)

3. We support **source maps** for SASS in development mode. There is a [great blog post](http://fonicmonkey.net/2013/03/25/native-sass-scss-source-map-support-in-chrome-and-rails/) explaining how to set it up and use it.

### Best Practices

In some places, we echo unescaped script tags back to the browser, so we need to be very careful not to expose those in any places where they could get executed.

* Never use ngBindHtmlUnsafe.
* Never use innerHTML unless displaying completely static data.

### Styleguide

* Use an editor that supports [.editorconfig](http://editorconfig.org/#overview). Feel free to have a look at the [editor plug-ins](http://editorconfig.org/#download)
* Use 2 spaces for indentation
* List items/properties alphabetically
* Remove `console.log()` messages when committing your code.
* Only use anchor tags `<a>` for actual links, otherwise use `<button>` instead. _This is especially important for IE9_.
* Use single quotes when possible

:-1:
```javascript
var name="Christian Vuerings";
```
:+1:
```javascript
var name='Christian Vuerings';
```

* Use `data-ng-` instead of `ng-` or `ng:` and add `data-` for directives

:-1:
```html
<ng:view>
<span ng-bind="name"></span>
<input mmddyyvalidator />
```
:+1:
```html
<div data-ng-view></div>
<span data-ng-bind="name"></span>
<input data-mmddyyvalidator />
```

## Recording fake data feeds and timeshifting them

Make sure your testext.local.yml file has real connections to real external services that are fakeable (Canvas, Google, etc).
Now do:

```bash
rake vcr:record
rake vcr:prettify
```

* vcr:record can also take a SPEC=".../my_favorite_spec.rb" to help limit the recordings.
* vcr:prettify can also take a REGEX_FILTER="my_raw_recording.json" to target a specific raw file.

You can now find the prettified files in fixtures/pretty_vcr_recordings. You can edit these files to put in tokens that
will be substituted on server startup. See config/initializers/timeshift.rb for the dictionary of substitutions. Edit
 the debug_json property of each response, and timeshift.rb will automatically convert debug_json to the format actually
 used by VCR.

## Rake tasks:

To view other rake task for the project: ```rake -T```

* ```rake spec:xml``` - Runs rake spec, but pipes the output to xml using the rspec_junit_formatter gem, for JUnit compatible test result reports
* ```rake vcr:record``` - Refresh vcr recordings and reformats the fixtures with formatted JSON output. Will also parse the reponse body's string into json output for legibility.
* ```rake vcr:list``` - List the available recordings captured in the fixtures.

## Memcached tasks:

A few rake tasks to help monitor statistics and more:

* ```rake memcached:clear_stats``` - Reset memcached stats from all cluster nodes
* ```rake memcached:empty``` - Invalidate all memcached keys from all cluster nodes
* ```rake memcached:get_stats``` - Fetch memcached stats from all cluster nodes

* Generally, if you `rake memcached:empty` ( __WARNING:__ do not run on the production cluster unless you know what you're doing), you should follow with an `rake memcached:clear_stats`.
* All three task take the optional param of "hosts." So, if say you weren't running these tasks on the cluster layers themselves, or only wanted to tinker with a certain subset of clusters: `rake memcached:get_stats hosts="localhost:11212,localhost:11213,localhost:11214"`

## Using the feature toggle:

To selectively enable/disable a feature, add a property to the "features" section of settings.yml, e.g.:

```
features:
  wizbang: false
  neato: true
```

After server restart, these properties will appear in each users' status feed. You can now use ```ng:show``` in Angular to wrap the feature, e.g.:

```html
<div data-ng-show="user.profile.features.neato">
  Some neato feature...
</div>
```
or, depending on the feature, it may make more sense to disable it in erb (so that Angular controllers are never invoked at all):

```
<% if Settings.features.neato %>
  <%= render 'templates/widgets/notifications' %>
<% end %>
```
