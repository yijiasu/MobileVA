'use strict';

vishope.directive('tableAttrDirective', function() {
    return {
        restrict: 'A',
        scope: {
        },
        link: function(scope, element, attrs) {
            var dom = angular.element('<div></div>');
            dom.addClass('thead-resizer');
            //element.after(dom);
            //dom.hide().appendTo(element).fadeIn(1000);
        }
    };
});
