'use strict';

vishope.controller('overviewCtrl', ['$scope', 'pipService', 'dataService', 'overviewVisService',
        function($scope, pipService, dataService, overviewVisService) {

    $scope.dataLoadFlag = 0;

    $scope.config = {
        startDate: undefined,
        endDate: undefined,
        startDateRange: [],
        endDateRange: [],
        viewOption: [],
        selectedView: undefined,
        selectedStartDate: undefined,
        selectedEndDate: undefined
    };

    pipService.onDatasetChange($scope, function(msg) {
        $scope.dataLoadFlag = 1;
        var dateTuple = dataService.getDateRange();
        $scope.config.startDate = dateTuple[0];
        $scope.config.endDate = dateTuple[1];
        $scope.config.startDateRange = genDateRange($scope.config.startDate, $scope.config.endDate);
        $scope.config.endDateRange = [];
        $scope.config.viewOption=["Scatter Plot", "Contour Map"];
        $scope.selectedStartDate = undefined;
        $scope.selectedEndDate = undefined;
        $scope.config.selectedView="Scatter Plot";
        overviewVisService.reset();
    });

     pipService.onHighlightChange($scope, function(node) {
            overviewVisService.highLightNodeFromTable(node);
        });


    $scope.updateStartDate = function() {
        if (!$scope.config.selectedStartDate) {
            $scope.config.endDateRange = [];
            $scope.config.selectedEndDate = undefined;
        } else {
            $scope.config.endDateRange = genDateRange($scope.config.selectedStartDate, $scope.config.endDate);
            if ($scope.config.selectedEndDate >= $scope.config.selectedStartDate) {
                $scope.updateOverview(genDateRange($scope.config.selectedStartDate, $scope.config.selectedEndDate));
            } else {
                $scope.config.selectedEndDate = undefined;
                overviewVisService.reset();
            }
        }
    };

    $scope.updateEndDate = function() {
        $scope.updateOverview(genDateRange($scope.config.selectedStartDate, $scope.config.selectedEndDate));
    };
    $scope.updateViewOption = function(){
        $scope.updateOverview(genDateRange($scope.config.selectedStartDate, $scope.config.selectedEndDate));
    };

    $scope.updateOverview = function(dateRange) {
        overviewVisService.updateOverview(dateRange,$scope.config.selectedView);
    };

    var genDateRange = function(start, end) {
        if (start < 10000) {
            return d3.range(start, end + 1);
        } else {
            var startYear = Math.floor(start / 100);
            var endYear = Math.floor(end / 100);
            var startMon = start % 100;
            var endMon = end % 100;
            if (startYear == endYear) {
                return d3.range(start, end + 1);
            } else {
                var res = [];
                for (var i = startMon; i <= 12; i++) {
                    res.push(startYear * 100 + i);
                }
                for (var i = startYear + 1; i < endYear; i++)
                    for (var j = 1; j <= 12; j++) {
                        res.push(i * 100 + j);
                }
                for (var i = 1; i <= endMon; i++) {
                    res.push(endYear * 100 + i);
                }
                return res;
            }
        }
    };

}]);
