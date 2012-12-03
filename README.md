#CalCentral

Home of CalCentral. [![Build status for calcentral](https://secure.travis-ci.org/ets-berkeley-edu/calcentral.png)](http://travis-ci.org/ets-berkeley-edu/calcentral)

## Dependencies

* [Bundler](http://gembundler.com/rails3.html)
* [Git](https://help.github.com/articles/set-up-git)
* [JDBC Oracle driver](http://www.oracle.com/technetwork/database/enterprise-edition/jdbc-112010-090769.html)
* [JRuby 1.7.0](http://jruby.org/)
* [PostgreSQL](http://www.postgresql.org/)
* [Rails 3.2.8](http://rubyonrails.org/download)
* [Rubygems](http://rubyforge.org/frs/?group_id=126)
* [Rvm](https://rvm.io/rvm/install/) - Ruby version managers

## Installation

1. Install postgres
```bash
brew update
brew install postgresql
initdb /usr/local/var/postgres
```

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
rvm install jruby-1.7.0
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

9. Install JDBC driver (for Oracle connection)
You may already have an Oracle driver from MyBerkeley-OAE development, in which case you just need to copy it to your local JRuby installation:
```cp ~/.m2/repository/com/oracle/ojdbc6/11.2.0.3/ojdbc6-11.2.0.3.jar ~/.rvm/rubies/jruby-1.7.0/lib/```
  * Otherwise, download [ojdbc6.jar](http://www.oracle.com/technetwork/database/enterprise-edition/jdbc-112010-090769.html)
  * Copy ojdbc6.jar to your local JRuby installation; e.g. ```~/.rvm/rubies/jruby-1.7.0/lib/```

10. Initialize PostgreSQL database tables
```bash
rake db:schema:load
```

11. Start the server
```bash
rails s
```

## LiveReload & Testing

See code changes happening live in the browser and look at the testing

Run `foreman start` in the terminal, it will:
* Start the rails server
* Expose the [jasmine](http://pivotal.github.com/jasmine/) tests at http://localhost:8888
* Start [Guard](https://github.com/guard/guard) for livereload.

## Debugging

### Emulating production mode locally

1. Precompile the assets: [(more info)](http://stackoverflow.com/questions/7275636/rails-3-1-0-actionviewtemplateerrror-application-css-isnt-precompiled)
```bash
bundle exec rake assets:precompile
```

2. Serve static assets through rails
```
config.serve_static_assets = true
```

3. Start the server in production mode
```bash
rails s -e production
```

4. After testing, remove the static assets and generated pages
```bash
bundle exec rake assets:clean
rm public/index.html
# remove other pages ...
```

### Test connection

Make sure you are on the Berkeley network or connected through [preconfigured VPN](https://kb.berkeley.edu/jivekb/entry.jspa?externalID=2665) for the Oracle connection.
If you use VPN, use group #1 (1-Campus_VPN)

### Tips

1. On Mac OS X, to get RubyMine to pick up the necessary environment variables, open a new shell, set the environment variables, and:
```bash
/Applications/RubyMine.app/Contents/MacOS/rubymine &
```

2. If you want to explore the Oracle database on Mac OS X, use [SQL Developer](http://www.oracle.com/technetwork/developer-tools/sql-developer/overview/index.html)

### Styleguide

* Use an editor that supports [.editorconfig](http://editorconfig.org/#overview). Feel free to have a look at the [editor plug-ins](http://editorconfig.org/#download)
* Use `data-ng-` instead of `ng-` or `ng:`

:-1:
```html
<ng:view>
<span ng-bind="name"></span>
```
:+1:
```html
<div data-ng-view></div>
<span data-ng-bind="name"></span>
```

## Freshening fake data feeds

Make sure your test.local.yml file has real connections to real external services that are fakeable (Canvas, Google, etc).
Now do:

```bash
rake spec freshen_vcr=true
git add fixtures/fakeable_proxy_data
git commit -a -m "Helpful commit message"
```

## Rake tasks:

To view other rake task for the project: ```rake -T```

* ```rake spec:xml``` - Runs rake spec, but pipes the output to xml using the rspec_junit_formatter gem, for JUnit compatible test result reports
