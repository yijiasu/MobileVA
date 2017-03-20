'use strict';

vishope.directive('baselineDirective', ['dataService', function(dataService) {
    return {
        restrict: 'A',
        scope: {
            drawEgoBaseline: '=',
            egoData: '='
        },
        link: function(scope, element, attrs) {
            scope.$watch('egoData', function() {
                scope.drawEgoBaseline(element[0], scope.egoData);
            });
            //scope.drawEgoBaseline(element[0], scope.egoData);
            scope.$watch('egoData.synScroll', function() {
                scope.egoData['synOnGoing'] = true;
                if (scope.egoData.synScroll) {
                    var scrollpos = dataService.getScrollPos(scrollpos);
                    angular.element(element[0]).animate({
                        scrollLeft: scrollpos
                    }, 800);
                }
                //scope.egoData['synOnGoing'] = false;
                //scope.drawSynScroll(element[0], scope.egoData, scope.egoData.synScroll);
            });
        }
    };
}]);
