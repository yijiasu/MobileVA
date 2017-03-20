'use strict';

vishope.directive('egoDirective', ['dataService', function(dataService) {
    return {
        restrict: 'A',
        scope: {
            drawEgoGlyph: '=',
            drawSynScroll: '=',
            drawEgoExpand: '=',
            reArrangeEgoExpand: '=',
            changeGlyph:'=',
            changeOrder:'=',
            changeColor:'=',
            egoData: '=',
            egoFilterNumber: '='
        },
        link: function(scope, element, attrs) {
            scope.drawEgoGlyph(element[0], scope.egoData);
            scope.$watch('egoData.synScroll', function() {
                scope.egoData['synOnGoing'] = true;
                if (scope.egoData.synScroll) {
                    var scrollpos = dataService.getScrollPos(scrollpos);
                    angular.element(element[0]).animate({
                        scrollLeft: scrollpos
                    }, 800);
                }
                //scope.egoData['synOnGoing'] = false;
                scope.drawSynScroll(element[0], scope.egoData, scope.egoData.synScroll);
            });
            scope.$watch('egoData.performanceFlag', function() {
                scope.changeColor(element[0], scope.egoData, scope.egoData.performanceFlag);
            });

             scope.$watch('egoData.pag', function() {
                scope.changeOrder(element[0], scope.egoData, scope.egoData.performanceFlag);
            });

            scope.$watch('egoData.rect', function() {
                scope.changeGlyph(element[0], scope.egoData, scope.egoData.rect);
            });


            scope.$watch('egoData.expansion', function() {
                scope.drawEgoExpand(element[0], scope.egoData, scope.egoData.expansion);
            });

            scope.$watch('egoData.filterNumber', function() {
                if (scope.egoData.filterNumber) {
                    scope.egoFilterNumber(element[0], scope.egoData, scope.egoData.filterNumber);
                }
            });

            scope.$watch('egoData.orderFlag', function() {
                scope.reArrangeEgoExpand(element[0], scope.egoData, scope.egoData.orderFlag);
            });
        }
    };
}]);
