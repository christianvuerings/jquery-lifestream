(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccYoutubeDirective', function($sce, $compile) {
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
            image: '<div id="cc-youtube-image-placeholder" class="cc-youtube-image-placeholder" tabindex="0"><img ng-src="' + imageUrl + '"></img><div class="cc-youtube-thumbnail-button"></div></div>',
            video: '<div id="cc-youtube-video-placeholder" class="cc-youtube-video-placeholder"><iframe type="text/html" width="100%" height="100%" src=' + videourl + ' frameborder="0" allowfullscreen></iframe></div>'
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

            // If you click the image or hit ENTER when it's focussed, start playing the video
            if (mode === 'image') {
              el.on('click', function() {
                launch('video');
              });
              el.on('keydown', function(event) {
                if (event.keyCode === 13) {
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
