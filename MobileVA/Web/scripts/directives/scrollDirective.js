'use strict';

vishope.directive('scrollDirective', ['dataService', function(dataService) {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            element.bind('scroll', function(e) {
                var scrollpos = element.scrollLeft();
                if ($('.synScroll') && (attrs.synFlag != 'false') && (attrs.synOnGoing != 'true')) {
                    dataService.setScrollPos(scrollpos);
                    $('.synScroll').animate({
                        scrollLeft: scrollpos
                    }, 0);
                }
            });
        }
    };
}]);
