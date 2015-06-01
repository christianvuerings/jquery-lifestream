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
        external: [
          // Date parsing
          'node_modules/moment/moment.js',
          // Libraries (google analytics)
          'src/assets/javascripts/lib/**/*.js',
          // Human Sorting in JavaScript
          'node_modules/js-natural-sort/dist/naturalSort.js',
          // Remote JavaScript error logging
          'node_modules/raven-js/dist/raven.js',
          // Datepicker
          'node_modules/pikaday/pikaday.js',
          // Angular
          'node_modules/angular/angular.js',
          // Angular Aria
          'node_modules/angular-aria/angular-aria.js',
          // Angular Routing
          'node_modules/angular-route/angular-route.js',
          // Angular Sanitize (avoid XSS exploits)
          'node_modules/angular-sanitize/angular-sanitize.js',
          // Angular Swipe Directive
          // TODO - remove as soon as
          // https://github.com/angular/angular.js/issues/4030 is fixed
          'src/assets/javascripts/angularlib/swipeDirective.js'
        ],
        // Our own files, we put this in a separate array to make sure we run
        // ng-annotate on it
        internal: [
          'src/assets/javascripts/**/*.js'
        ],
        // The JS templates files ($templateCache)
        templates: [
          'public/assets/templates/templates.js'
        ]
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
      js: 'public/assets/javascripts',
      templates: 'public/assets/templates'
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
   * Templates task
   *   Concatenate the contents of all .html-files in the templates directory
   *   and save to public/templates.js
   */
  gulp.task('templates', function() {
    // Template cache will put all the .html files in the angular templateCache
    var templateCache = require('gulp-angular-templatecache');

    return gulp.src(paths.src.templates)
      .pipe(templateCache({
        // Creates a standalone module called 'templates'
        // This makes it easier to load in CalCentral
        standalone: true
      }))
      .pipe(gulp.dest(paths.dist.templates));
  });

  /**
   * JavaScript task
   *   Add annotations (production)
   *   Minify (production)
   *   Concatenate
   * We need to make sure the templates.js file is included into the
   * concatenated files.
   */
  gulp.task('js', ['templates'], function() {
    var concat = require('gulp-concat');
    var ngAnnotate = require('gulp-ng-annotate');
    var uglify = require('gulp-uglify');

    // Combine the templates JS and reqular JS
    var streamqueue = require('streamqueue');
    return streamqueue({
        objectMode: true
      },
      gulp.src(paths.src.js.external),
      gulp.src(paths.src.js.internal)
        // Annotate the internal AngularJS files in production
        .pipe(gulpif(isProduction, ngAnnotate())
      ),
      gulp.src(paths.src.js.templates))
      .pipe(gulpif(isProduction, uglify()))
      .pipe(concat('application.js'))
      .pipe(gulp.dest(paths.dist.js));
  });

  /**
   * Index & bCourses task
   */
  gulp.task('index', ['images', 'templates', 'js', 'css', 'fonts'], function() {
    // Plug-in to inject html into other html
    var inject = require('gulp-inject');

    // Combine the index and bCourses streams
    var streamqueue = require('streamqueue');

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

    // Run the 2 index & bCourses stream in parallell
    return streamqueue({
        objectMode: true
      },
      gulp.src(paths.src.mainTemplates.base)
        .pipe(inject(
          gulp.src(paths.src.mainTemplates.index),
          injectOptions
        ))
        .pipe(rename({
          basename: 'index-main'
        }))
        .pipe(gulp.dest('public')),
      gulp.src(paths.src.mainTemplates.base)
        .pipe(inject(
          gulp.src(paths.src.mainTemplates.bcoursesEmbedded),
          injectOptions
        ))
        .pipe(rename({
          basename: 'bcourses_embedded'
        }))
        .pipe(gulp.dest('public'))
      );
  });

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
        return path.basename(file.path, extension) + '-'  + hash.substr(0, 20) + extension;
      }
    });

    return gulp.src([
        paths.src.assetsPublic,
        paths.src.mainTemplates.bcoursesEmbeddedPublic,
        paths.src.mainTemplates.indexPublic
      ], {
        base: 'assets'
      })
      .pipe(revAllAssets.revision())
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
    gulp.watch(paths.src.js.internal, ['js']);
    gulp.watch(paths.src.templates, ['js']);
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
        'templates',
        'js',
        'css',
        'fonts',
        'index'
      ],
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
