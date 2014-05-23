(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccYoutubeDirective', function(apiService, $compile, $sce, $timeout) {
    return {
      restrict: 'ACE',
      replace: true,
      link: function(scope, elem, attrs) {
        scope.$watch(attrs.ccYoutubeDirective, function(value) {
          var videoid = value;
          var videourl = 'https://www.youtube.com/embed/' + videoid + '?version=3&f=playlists&app=youtube_gdata&showinfo=0&theme=light&modestbranding=1&autoplay=1';
          var imageUrl = $sce.trustAsResourceUrl('https://img.youtube.com/vi/' + videoid + '/hqdefault.jpg');

          // Templates for the player
          var templates = {
            image: '<button id="cc-youtube-image-placeholder" class="cc-youtube-image-placeholder" tabindex="0"><span class="cc-visuallyhidden">Play video</span><img ng-src="' + imageUrl + '" alt=""></img><div class="cc-youtube-thumbnail-button"></div></button>',
            video: '<div id="cc-youtube-video-placeholder" class="cc-youtube-video-placeholder" tabindex="0"><iframe type="text/html" width="100%" height="100%" src=' + videourl + ' frameborder="0" allowfullscreen></iframe></div>'
          };

          /**
           * Launch the correct mode
           * @param {String} mode 'image' or 'video'
           */
          var launch = function(mode) {

            // Remove both placeholders
            angular.element(document.querySelector('#cc-youtube-image-placeholder')).remove();
            angular.element(document.querySelector('#cc-youtube-video-placeholder')).remove();

            // Create an angular element, contents depend on the mode
            var el = angular.element(templates[mode]);

            // Compile the element and append it to the container element
            var compiled = $compile(el);
            elem.append(el);

            // When we launch the video, make sure to focus on the youtube player
            if (mode === 'video') {
              apiService.analytics.sendEvent('Video', 'Play', 'Webcast');
              $timeout(function() {
                el[0].focus();
              }, 1);
            }

            if (mode === 'image') {
              // If you click the image, start playing the video
              el.on('click', function() {
                launch('video');
              });
              el.on('keydown', function(event) {
                // If you hit ENTER or SPACE when it's focussed, start playing the video
                if (event.keyCode === 13 || event.keyCode === 32) {
                  launch('video');
                }
              });
            }
            compiled(scope);
          };

          // If there is a video id, launch the image mode
          if (videoid) {
            launch('image');
          }

        });
      }
    };

  });

})(window.angular);
