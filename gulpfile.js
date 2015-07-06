/* jshint node:true */
(function() {
  'use strict';

  // Load gulp
  var gulp = require('gulp');

  // Allows for conditional statements in gulp
  var gulpif = require('gulp-if');

  // Read options from the command line
  var minimist = require('minimist');

  // Rename files
  var rename = require('gulp-rename');

  // Plug-in to inject html into other html
  var inject = require('gulp-inject');

  // Browserify dependencies
  var browserify = require('browserify');
  var watchify = require('watchify');
  var bulkify = require('bulkify');
  var source = require('vinyl-source-stream');
  var addStream = require('add-stream');
  var streamify = require('gulp-streamify');
  var ngAnnotate = require('gulp-ng-annotate');
  var concat = require('gulp-concat');
  var uglify = require('gulp-uglify');
  var util = require('gulp-util');

  // Base options for the command line
  var baseOptions = {
    string: 'env',
    default: {
      env: process.env.RAILS_ENV || 'development'
    }
  };

  // Slice all the command options and set the defaults
  var options = minimist(process.argv.slice(2), baseOptions);

  // Are we in production mode?
  var isProduction = options.env === 'production';

  // Check if Watchify has been turned on so it is only executed once
  var watchifyOn = false;

  // List all the used paths
  var paths = {
    // Source files
    src: {
      // Public assets
      assetsPublic: 'public/assets/**',
      // CSS files
      css: [
        // CSS Framework
        'src/assets/stylesheets/lib/foundation.css',
        // Font Awesome
        'node_modules/font-awesome/css/font-awesome.css',
        // Datepicker
        'node_modules/pikaday/css/pikaday.css'
      ],
      cssWatch: [
        'src/assets/stylesheets/**/*.*'
      ],
      // SCSS Files
      scss: [
        // Main CSS File
        'src/assets/stylesheets/calcentral.scss'
      ],
      // All the fonts
      fonts: [
        'node_modules/font-awesome/fonts/**/*.*'
      ],
      // Images
      img: 'src/assets/images/**/*.*',
      // JavaScript
      js: {
        // Public JavaScript
        external: 'public/assets/javascripts/index.js',
        // Browserify creates bundled JS with internal JS files
        internal: 'src/assets/javascripts/index.js'
      },
      // Main templates (not used for inclusing in AngularJS templates)
      mainTemplates: {
        // base file
        base: 'src/base.html',
        // bCourses Embedded file
        bcoursesEmbedded: 'src/bcourses_embedded.html',
        // bCourses Embedded public file
        bcoursesEmbeddedPublic: 'public/bcourses_embedded.html',
        // index file. If it's named index.html, BootstrapController gets skipped due to
        // hardcoded Rails assumptions about static asset serving. We always want BootstrapController
        // in the processing chain, so our index is called index-main.html.
        index: 'src/index-main.html',
        // index-main.html public file
        indexPublic: 'public/index-main.html',
        // html files in public/assets
        publicAssets: 'public/assets/*.html',
        // All html files in the source
        source: 'public/*.html'
      },
      // List the HTML template files
      // Will be converted into templates.js
      templates: 'src/assets/templates/**/*.html'
    },
    // Build files
    dist: {
      css: 'public/assets/stylesheets',
      fonts: 'public/assets/fonts',
      img: 'public/assets/images',
      js: 'public/assets/javascripts'
    }
  };

  /**
   * Images task
   *   Copy files
   */
  gulp.task('images', function() {
    return gulp.src(paths.src.img)
      .pipe(gulp.dest(paths.dist.img));
  });

  /**
   * CSS Task
   *   Add prefixes
   *   Convert SASS to CSS
   *   Base64 (production)
   *   Minify (production)
   *   Concatenate
   *   Copy files
   */
  gulp.task('css', function() {
    // Automatically add browser prefixes (e.g. -webkit) when necessary
    var autoprefixer = require('gulp-autoprefixer');
    // Concatenate the files
    var concat = require('gulp-concat');
    // Convert the .scss files into .css
    var sass = require('gulp-sass');
    // We need the to combine the CSS and SCSS streams
    var streamqueue = require('streamqueue');
    // Base 64 encoding of images
    var base64 = require('gulp-base64');
    // Minify the CSS in production
    var minifyCSS = require('gulp-minify-css');

    return streamqueue({
        // Streams that are in object mode can emit generic JavaScript values
        // other than Buffers and Strings.
        objectMode: true
      },
      gulp.src(paths.src.css),
      gulp.src(paths.src.scss)
        .pipe(sass())
        .pipe(autoprefixer({
          // We don't need the visual cascade of prefixes
          // https://github.com/postcss/autoprefixer#visual-cascade
          cascade: false
        })
      ))
      // Base 64 encode certain images
      .pipe(gulpif(isProduction, base64()))
      // Minify CSS
      .pipe(gulpif(isProduction, minifyCSS()))
      // Combine the files
      .pipe(concat('application.css'))
      // Output to the correct directory
      .pipe(gulp.dest(paths.dist.css));
  });

  /**
   * Fonts task
   *   Copy files
   */
  gulp.task('fonts', function() {
    return gulp.src(paths.src.fonts)
      .pipe(gulp.dest(paths.dist.fonts)
    );
  });

  /**
   * Templates function
   *   Concatenate the contents of all .html-files in the templates directory
   *   and save to public/templates.js
   */
  var prepareTemplates = function() {
    // Template cache will put all the .html files in the angular templateCache
    var templateCache = require('gulp-angular-templatecache');
    // Minify our html templates
    var minifyHTML = require('gulp-minify-html');

    // Minify options
    var minifyOptions = {
      // Do not remove conditional internet explorer comments
      conditionals: true,
      // Do not remove empty attributes used by Angular
      empty: true,
      // Preserve one whitespace
      loose: true
    };
    return gulp.src(paths.src.templates)
    .pipe(minifyHTML(minifyOptions))
    .pipe(templateCache({
      // Creates a standalone module called 'templates'
      // This makes it easier to load in CalCentral
      standalone: true
    }));
  };

  /**
   * bundleShare function
   *   Bundling process for initial bundle and update for Browserify task
   *   @param {object} bundle - bundler produced by browserify (during prod) or watchify (during dev)
   *   @return                - returns application.js file in public JS directory
   */
  var bundleShare = function(bundle) {
    return bundle.transform(bulkify)
      .bundle()
      .pipe(source('index.js'))
      // Annotate the internal AngularJS files in production
      .pipe(streamify(gulpif(isProduction, ngAnnotate())))
      .pipe(addStream.obj(prepareTemplates()))
      .pipe(streamify(concat('application.js')))
      .pipe(streamify(gulpif(isProduction, uglify())))
      .pipe(gulp.dest(paths.dist.js));
  };

  /**
   * Browserify Task
   *   Bundles all JS files using browserify
   *   Add annotations (production)
   *   Uglify (production)
   *   Concatenates minified templates
   *
   *   Watchify tracks any NEW changes made to any internal JS files
   */
  gulp.task('browserify', function() {
    var bundler = browserify({
      entries: [paths.src.js.internal],
      // Enables cache to be used for Watchify
      cache: {},
      packageCache: {},
      fullPaths: true,
      // Use source map if development mode
      // Source map shows the exact file and line when there is an error
      debug: !isProduction
    });
    if (!isProduction) {
      var watcher = watchify(bundler);
      if (!watchifyOn) {
        watchifyOn = true;
        // When any files update
        watcher.on('update', function() {
          util.log('Changed detected! Starting watchify ...');
          var updateStart = Date.now();
          // Create new bundle that uses the cache for high performance
          bundleShare(watcher);
          util.log('Update complete. Finished watchify after', util.colors.magenta(Date.now() - updateStart + ' ms'));
        });
      }
      // Create initial bundle when starting the task
      return bundleShare(watcher);
    } else {
      return bundleShare(bundler);
    }
  });

  // Options for the injection
  var injectOptions = {
    // Which tag to look for the in base html
    starttag: '<!-- inject:body:{{ext}} -->',
    transform: function(filePath, file) {
      // Return file contents as string
      return file.contents.toString('utf8');
    },
    // Remove the tags after injection
    removeTags: true
  };

  /**
   * Inject file paths into an html page
   */
  var injectPage = function(source, baseName) {
    return gulp.src(paths.src.mainTemplates.base)
      .pipe(inject(
        gulp.src(source),
        injectOptions
      ))
      .pipe(rename({
        basename: baseName
      }))
      .pipe(gulp.dest('public'));
  };

  /**
   * Inject the CSS / JS in the main index page
   */
  gulp.task('index-main', function() {
    return injectPage(paths.src.mainTemplates.index, 'index-main');
  });

  /**
   * Inject the CSS / JS in the bCourses embedded page
   */
  gulp.task('index-bcourses', function() {
    return injectPage(paths.src.mainTemplates.bcoursesEmbedded, 'bcourses_embedded');
  });

  /**
   * Index & bCourses task
   */
  gulp.task('index', ['index-main', 'index-bcourses']);

  /**
   * Mode the index & bCourses file back to the main public directory. (production)
   */
  gulp.task('revmove', function() {
    if (!isProduction) {
      return;
    }

    return gulp.src(paths.src.mainTemplates.publicAssets)
      .pipe(gulp.dest('public'));
  });

  /**
   * Add hashes to the files and update the includes (production)
   */
  gulp.task('revall', function() {
    if (!isProduction) {
      return;
    }

    var path = require('path');
    var RevAll = require('gulp-rev-all');
    var revAllAssets = new RevAll({
      // Since we only run this in production mode, add some extra logging
      debug: true,
      dontGlobal: [
        /favicon\.ico/g,
        'manifest.json'
      ],
      dontRenameFile: [
        /^(.+)\.html$/g
      ],
      // Increase the hashlength from 5 to 20 to avoid collisions
      hashLength: 20,
      // We can't have dots in our filenames, other wise we get a InvalidCrossOriginRequest response
      transformFilename: function(file, hash) {
        var extension = path.extname(file.path);
        // filename-6546259a4f83fd81debc.extension
        return path.basename(file.path, extension) + '-' + hash.substr(0, 20) + extension;
      }
    });

    return gulp.src([
        paths.src.assetsPublic,
        paths.src.mainTemplates.bcoursesEmbeddedPublic,
        paths.src.mainTemplates.indexPublic
      ])
      .pipe(revAllAssets.revision())
      .pipe(gulp.dest('public/'))
      // Will add a manifest file at public/rev-manifest.json for debugging purposes
      .pipe(revAllAssets.manifestFile())
      .pipe(gulp.dest('public/')
    );

    // Keep the following lines for debugging purposes
    // This puts out a manifest file with the links to all the resources
    // e.g. "fonts/FontAwesome.otf": "/fonts/FontAwesome.4f97a8a6.otf",
    // .pipe(revall.manifest())
    // .pipe(gulp.dest('public/assets/'));
  });

  /**
   * Build Clean task
   * Remove all the files generated by the build
   */
  gulp.task('build-clean', function(callback) {
    var del = require('del');
    del(
      [
        paths.src.assetsPublic,
        paths.src.mainTemplates.bcoursesEmbeddedPublic,
        paths.src.mainTemplates.indexPublic
      ], callback);
  });

  /**
   * Watch task - watch files for changes (development)
   * TODO add http://www.browsersync.io/docs/gulp/#gulp-manual-reload
   */
  gulp.task('watch', function() {
    if (isProduction) {
      return;
    }

    gulp.watch(paths.src.mainTemplates.source, ['index']);
    gulp.watch(paths.src.cssWatch, ['css']);
    gulp.watch(paths.src.fonts, ['fonts']);
    gulp.watch(paths.src.templates, ['browserify']);
    gulp.watch(paths.src.img, ['images']);
  });

  /**
   * Build task
   * We build all the files in this task, we need to make sure the clean-up
   * happens before everything else
   */
  gulp.task('build', function(callback) {
    var runSequence = require('run-sequence');

    runSequence(
      'build-clean',
      [
        'images',
        'browserify',
        'css',
        'fonts'
      ],
      'index',
      'revall',
      'revmove',
      'watch',
      callback);
  });

  /**
   * Default task - executed when you run the 'gulp' command
   */
  gulp.task('default', ['build']);
})();
