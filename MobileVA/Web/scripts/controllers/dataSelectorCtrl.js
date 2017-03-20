'use strict';

vishope.controller('dataSelectorCtrl', ['$scope', 'pipService', 'dataService',
        function($scope, pipService, dataService) {

    $scope.data = {
        'dbList': []
    };

    dataService.getDBList().then(function(promise) {
        $scope.data.dbList = promise.data;
    });

    $scope.updateDataset = function(selectedDataset) {
        dataService.updateDataset(selectedDataset).then(function(promise) {
            $scope.data.dataset = promise.data;
            pipService.emitDatasetChange('from:dataSelectorCtrl');
        });
    };

    $scope.controlPanel = function() {
        pipService.emitControlPanel();
    };

    $scope.heatmap = function() {
        pipService.emitHeatmap();
    };
}]);
