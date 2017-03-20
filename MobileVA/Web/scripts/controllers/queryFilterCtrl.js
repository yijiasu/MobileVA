'use strict';

vishope.controller('queryFilterCtrl', ['$scope', 'pipService', 'dataService',
        function($scope, pipService, dataService) {

    $scope.dataLoadFlag = 0;
    $scope.queryData = {
        searchText: ''
    };

    pipService.onDatasetChange($scope, function(msg) {
        $scope.dataLoadFlag = 1;
    });

    $scope.search = function() {
        pipService.emitSearchEgo($scope.queryData.searchText);
    };

    $scope.reset = function() {
        $scope.queryData.searchText = '';
        pipService.emitResetEgo();
    };
}]);
