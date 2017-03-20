'use strict';

vishope.controller('baselineCtrl', ['$scope', 'pipService',
    'dataService', 'baselineService', function($scope, pipService, dataService, baselineService) {
        $scope.screenHeight = screen.height - 130;
        $scope.egoList = [];
        $scope.scrollpos = 0;
        $scope.timelineConfig = {
            startYear: undefined,
            endYear: undefined,
            basicWidth: 100,
            width: 0
        };

        pipService.onHighlightBSChange($scope, function(node) {
            var egoID = node['id'];
            if (node.highlight) {
                $scope.egoList = addEgo(node);
            } else {
                $scope.egoList = removeEgo(node);
            }
            setTimelineConfig();
        });

        var setTimelineConfig = function() {
            //var highlightNodeDict = dataService.getHighlightNodeDict();
            var highlightNodeDict = $scope.egoList;
            $scope.timelineConfig.startYear = undefined;
            $scope.timelineConfig.endYear = undefined;
            for (var key in highlightNodeDict) {
                if (highlightNodeDict.hasOwnProperty(key)) {
                    if (($scope.timelineConfig.startYear == undefined) ||
                            ($scope.timelineConfig.startYear > highlightNodeDict[key]['startYear'])) {
                                $scope.timelineConfig.startYear = highlightNodeDict[key]['startYear'];
                            }
                    if (($scope.timelineConfig.endYear == undefined) ||
                            ($scope.timelineConfig.endYear < highlightNodeDict[key]['endYear'])) {
                                $scope.timelineConfig.endYear = highlightNodeDict[key]['endYear'];
                            }
                }
            }
            var len = genYearDistance($scope.timelineConfig.startYear, $scope.timelineConfig.endYear) + 1;
            if ($scope.timelineConfig.startYear == undefined || $scope.timelineConfig.endYear == undefined) {
                len = 0;
            }
            $scope.timelineConfig.width = $scope.timelineConfig.basicWidth * len;
            baselineService.updateTimeline($scope.timelineConfig);
        };

        var genYearDistance = function(start, end) {
            if (start < 10000) {
                return end - start + 6;
            } else {
                var stYear = Math.floor(start / 100);
                var edYear = Math.floor(end / 100);
                var stMon = start % 100;
                var edMon = end % 100;
                if (stYear == edYear) {
                    return edMon - stMon;
                } else {
                    return (edYear - stYear - 1) * 12 + 12 - stMon + edMon;
                }
            }
        };

        var addEgo = function(node) {
            var egoID = node['id'];
            for (var i = 0; i < $scope.egoList.length; i++) {
                if ($scope.egoList[i]['id'] == egoID) {
                    return $scope.egoList;
                }
            }
            $scope.egoList.push(node);
            return $scope.egoList;
        };

        var removeEgo = function(node) {
            var egoID = node['id'];
            for (var i = 0; i < $scope.egoList.length; i++) {
                if ($scope.egoList[i]['id'] == egoID) {
                    $scope.egoList.splice(i, 1);
                    break;
                }
            }
            return $scope.egoList;
        };

        $scope.clearEgoList = function() {
            $scope.egoList = [];
        };

        pipService.onClearEgoBSList($scope, function(msg) {
            $scope.clearEgoList();
        });

        $scope.drawEgoBaseline = function(element, egoData) {
            baselineService.drawEgoBaseline(element, egoData);
        };

        //$scope.changeScroll = function(index) {
            //var ego = $scope.egoList[index];
            //ego.synScroll = !ego.synScroll;
            //if (ego.synScroll) {
                //var scrollpos = dataService.getScrollPos();
                //$('.synScroll').animate({
                    //scrollLeft: scrollpos
                //}, 0);
            //}
        //};
    }]);
