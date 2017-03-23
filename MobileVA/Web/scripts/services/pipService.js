'use strict';

vishope.factory('pipService', ['$rootScope', function($rootScope) {
    var DATASET_CHANGE = 'datasetChange';
    var HIGHLIGHT_CHANGE = 'highlightChange';
    var REMOVE_HIGHLIGHT = 'removeHighlight';
    var CONTROL_PANEL = 'controlPanel';
    var HEATMAP = 'heatmap';
    var SEARCH_EGO = 'searchEgo';
    var RESET_EGO = 'resetEgo';
    var CLEAR_EGOLIST = 'clearEgoList';
    var CLEAR_EGOBSLIST = 'BSclearEgoList';
    var HIGHLIGHTBS_CHANGE = 'BSChange';
    var EXPAND = 'expand';
    var OVERVIEW_CLICKED = 'overviewClicked'
    var ALTER_DOUBLECLICKED = 'alterDoubleClicked'

    var pipService = {};

    pipService.emitDatasetChange = function(msg) {
        $rootScope.$broadcast(DATASET_CHANGE, msg);
    };

    pipService.onDatasetChange = function(scope, callback) {
        scope.$on(DATASET_CHANGE, function(event, msg) {
            callback(msg);
        });
    };

    pipService.emitHighlightChange = function(msg) {
        $rootScope.$broadcast(HIGHLIGHT_CHANGE, msg);
    };

    pipService.onHighlightChange = function(scope, callback) {
        scope.$on(HIGHLIGHT_CHANGE, function(event, msg) {
            callback(msg);
        });
    };

    pipService.emitRemoveHighlight = function(msg) {
        $rootScope.$broadcast(REMOVE_HIGHLIGHT, msg);
    };

    pipService.onRemoveHighlight = function(scope, callback) {
        scope.$on(REMOVE_HIGHLIGHT, function(event, msg) {
            callback(msg);
        });
    };

    pipService.emitControlPanel = function(msg) {
        $rootScope.$broadcast(CONTROL_PANEL, msg);
    };

    pipService.onControlPanel = function(scope, callback) {
        scope.$on(CONTROL_PANEL, function(event, msg) {
            callback(msg);
        });
    };

    pipService.emitHeatmap = function(msg) {
        $rootScope.$broadcast(HEATMAP, msg);
    };

    pipService.onHeatmap = function(scope, callback) {
        scope.$on(HEATMAP, function(event, msg) {
            callback(msg);
        });
    };

    pipService.emitSearchEgo = function(msg) {
        $rootScope.$broadcast(SEARCH_EGO, msg);
    };

    pipService.onSearchEgo = function(scope, callback) {
        scope.$on(SEARCH_EGO, function(event, msg) {
            callback(msg);
        });
    };

    pipService.emitResetEgo = function(msg) {
        $rootScope.$broadcast(RESET_EGO, msg);
    };

    pipService.onResetEgo = function(scope, callback) {
        scope.$on(RESET_EGO, function(event, msg) {
            callback(msg);
        });
    };

    pipService.emitClearEgoList = function(msg) {
        $rootScope.$broadcast(CLEAR_EGOLIST, msg);
    };

    pipService.onClearEgoList = function(scope, callback) {
        scope.$on(CLEAR_EGOLIST, function(event, msg) {
            callback(msg);
        });
    };

    pipService.emitClearEgoBSList = function(msg) {
        $rootScope.$broadcast(CLEAR_EGOBSLIST, msg);
    };

    pipService.onClearEgoBSList = function(scope, callback) {
        scope.$on(CLEAR_EGOBSLIST, function(event, msg) {
            callback(msg);
        });
    };

    pipService.emitHighlightBSChange = function(msg) {
        $rootScope.$broadcast(HIGHLIGHTBS_CHANGE, msg);
    };

    pipService.onHighlightBSChange = function(scope, callback) {
        scope.$on(HIGHLIGHTBS_CHANGE, function(event, msg) {
            callback(msg);
        });
    };

    pipService.emitExpand = function(msg) {
        $rootScope.$broadcast(EXPAND, msg);
    };

    pipService.onExpand = function(scope, callback) {
        scope.$on(EXPAND, function(event, msg) {
            callback(msg);
        });
    };
     pipService.emitOverviewClicked = function(msg) {
        $rootScope.$broadcast(OVERVIEW_CLICKED, msg);
    };

    pipService.onOverviewClicked = function(scope, callback) {
        console.log("pipService.onOverviewClicked");
        scope.$on(OVERVIEW_CLICKED, function(event, msg) {
            callback(msg);
        });
    };
    pipService.emitAlterDoubleClicked = function(msg) {
        $rootScope.$broadcast(ALTER_DOUBLECLICKED, msg);
    };
    pipService.onAlterDoubleClicked = function(scope, callback) {
        scope.$on(ALTER_DOUBLECLICKED, function(event, msg) {
            callback(msg);
        });
    };
   return pipService;
}]);
