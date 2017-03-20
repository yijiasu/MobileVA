'use strict';

vishope.controller('uiCtrl', ['$scope', 'pipService',
    'dataService', function($scope, pipService, dataService) {
        $scope.uiConfig = {};
        $scope.uiConfig['mainWidth'] = 'col-sm-9 col-md-9';
        $scope.uiConfig['hideControlPanel'] = false;
        $scope.uiConfig['hideHeatmap'] = true;

        pipService.onControlPanel($scope, function(msg) {
            $scope.uiConfig['hideControlPanel'] = !$scope.uiConfig['hideControlPanel'];
            if ($scope.uiConfig['hideControlPanel'] && $scope.uiConfig['hideHeatmap']) {
                $scope.uiConfig['mainWidth'] = 'col-sm-12 col-md-12';
            } else if ($scope.uiConfig['hideControlPanel']) {
                $scope.uiConfig['mainWidth'] = 'col-sm-10 col-md-10 col-sm-offset-2 col-md-offset-2';
            } else if ($scope.uiConfig['hideHeatmap']) {
                $scope.uiConfig['mainWidth'] = 'col-sm-9 col-md-9';
            } else {
                $scope.uiConfig['mainWidth'] = 'col-sm-7 col-md-7 col-sm-offset-2 col-md-offset-2';
            }
        });

        pipService.onHeatmap($scope, function(msg) {
            $scope.uiConfig['hideHeatmap'] = !$scope.uiConfig['hideHeatmap'];
            if ($scope.uiConfig['hideControlPanel'] && $scope.uiConfig['hideHeatmap']) {
                $scope.uiConfig['mainWidth'] = 'col-sm-12 col-md-12';
            } else if ($scope.uiConfig['hideControlPanel']) {
                $scope.uiConfig['mainWidth'] = 'col-sm-10 col-md-10 col-sm-offset-2 col-md-offset-2';
            } else if ($scope.uiConfig['hideHeatmap']) {
                $scope.uiConfig['mainWidth'] = 'col-sm-9 col-md-9';
            } else {
                $scope.uiConfig['mainWidth'] = 'col-sm-7 col-md-7 col-sm-offset-2 col-md-offset-2';
            }
        });
    }]);
