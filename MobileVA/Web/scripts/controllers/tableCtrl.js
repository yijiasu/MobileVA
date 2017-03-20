'use strict';

vishope.controller('tableCtrl', ['$scope', 'pipService', 'dataService',
    function ($scope, pipService, dataService) {

        $scope.nodesData = dataService.getNodeObjList();
        $scope.originNodesData = $scope.nodesData;
        $scope.highlightNodeDict = dataService.getHighlightNodeDict();

        $scope.tableConfig = {
            thNodeWidth: 0.3,
            thAttrWidth: 0.7,
            paginationMaxSize: 5,
            itemsPerPage: 50,
            percentages: []
        };

        $scope.currentNodes = undefined;

        var initTable = function (nodeSchema) {
            $scope.tableConfig.tableAttributes = initTableAttributes(nodeSchema);
            $scope.tableConfig.percentages =
                $scope.tableConfig.tableAttributes.values.map(function (attr) {
                    return attr.percentage;
                });
            $scope.nodesData = initialSort(dataService.getNodeObjList());
            $scope.originNodesData = $scope.nodesData;
            $scope.tableConfig.totalLength = $scope.nodesData.length;
            $scope.tableConfig.currentPage = 1;
        };

        if ($scope.nodesData != undefined) {
            dataService.getNodeSchema().then(function (promise) {
                initTable(promise.data);
                var page = $scope.tableConfig.currentPage;
                $scope.currentNodes = getCurrentNodes(page);
            }, function (promise) {
                alert('Error loading node schema!');
            });
        }

        pipService.onDatasetChange($scope, function (msg) {
            dataService.getNodeSchema().then(function (promise) {
                initTable(promise.data);
                var page = $scope.tableConfig.currentPage;
                $scope.currentNodes = getCurrentNodes(page);
            }, function (promise) {
                alert('Error loading node schema!');
            });
        });

        pipService.onRemoveHighlight($scope, function (node) {
            for (var i = 0; i < $scope.nodesData.length; i++) {
                if ($scope.originNodesData[i]['id'] == node['id']) {
                    $scope.originNodesData[i]['highlight'] = false;
                    break;
                }
            }
        });

        pipService.onSearchEgo($scope, function (msg) {
            var res = [];
            for (var i = 0; i < $scope.originNodesData.length; i++) {
                if ($scope.originNodesData[i]['id'].indexOf(msg) > -1) {
                    res.push($scope.originNodesData[i]);
                }
            }
            $scope.nodesData = res;
            $scope.tableConfig.currentPage = 1;
            $scope.tableConfig.totalLength = $scope.nodesData.length;
            $scope.currentNodes = getCurrentNodes(1);
        });

        pipService.onResetEgo($scope, function (msg) {
            $scope.nodesData = $scope.originNodesData;
            $scope.tableConfig.totalLength = $scope.nodesData.length;
            $scope.tableConfig.currentPage = 1;
            $scope.currentNodes = getCurrentNodes(1);
        });

        pipService.onOverviewClicked($scope, function (msg) {
            var node;
            for (var i = 0; i < $scope.nodesData.length; i++) {
                if ($scope.nodesData[i]['id'] == msg) {
                    node = $scope.nodesData[i];
                    break;
                }
            }
            node.highlight = !node.highlight;
            dataService.setHighlightNode(node, node.highlight);
            pipService.emitHighlightChange(node);
            $scope.$apply();
        });

        pipService.onAlterDoubleClicked($scope, function (msg) {
            var node;
            var hasData = false;
            for (var i = 0; i < $scope.nodesData.length; i++) {
                if ($scope.nodesData[i]['id'] == msg) {
                    node = $scope.nodesData[i];
                    hasData = true;
                    break;
                }
            }
            if (hasData) {
                node.highlight = !node.highlight;
                dataService.setHighlightNode(node, node.highlight);
                pipService.emitHighlightChange(node);
                $scope.$apply();
            }
        });

        $scope.$watch('tableConfig.currentPage', function () {
            if ($scope.nodesData != undefined) {
                var page = $scope.tableConfig.currentPage;
                $scope.currentNodes = getCurrentNodes(page);
            }
        });

        var genFilterRange = function (dict) {
            var max = 1;
            for (var key in dict) {
                if (dict.hasOwnProperty(key)) {
                    if (dict[key] > max) {
                        max = dict[key];
                    }
                }
            }
            if (max - 1 > 19) {
                var step = max / 20;
                var res = [];
                for (var i = 0; i < 19; i++) {
                    res.push(Math.floor(1 + i * step));
                }
                return res;
            } else {
                return d3.range(1, max);
            }
        };

        var initialSort = function (dataset) {
            var nodes = [];
            var attrs = $scope.tableConfig.tableAttributes.values;
            var keyName = $scope.tableConfig.tableAttributes.key.name;

            for (var i = 0; i < dataset.length; i++) {
                nodes[i] = {};
                nodes[i][keyName] = dataset[i][keyName];
                nodes[i].id = dataset[i][keyName];
                nodes[i].neighbors = dataset[i]['neighbors'];
                nodes[i].allNeighborDict = dataset[i]['allNeighborDict'];
                nodes[i].yearDict = dataset[i]['yearDict'];
                nodes[i].filterRange = genFilterRange(dataset[i]['allNeighborDict']);
                //nodes[i].scores = [];
                //nodes[i].totalScore = 0;
                //nodes[i].rawIndex = i;
                if ($scope.highlightNodeDict.hasOwnProperty(nodes[i].id)) {
                    nodes[i].highlight = true;
                } else {
                    nodes[i].highlight = false;
                }
                nodes[i].synScroll = true;
                nodes[i].performanceFlag = false;
                nodes[i].orderFlag = false;
                for (var j = 0; j < attrs.length; j++) {
                    var attrName = attrs[j]['name'];
                    nodes[i][attrName] = dataset[i][attrName];
                }
            }
            sort(nodes, 'publication', 'Float');
            return nodes;
        };

        var sort = function (nodes, name, type) {
            //var keyName = $scope.tableConfig.tableAttributes.key.name;
            if (type == 'String') {
                nodes.sort(function (a, b) {
                    return a[name].localeCompare(b[name]);
                });
            } else {
                nodes.sort(function (a, b) {
                    return a[name] - b[name];
                });
                nodes.reverse();
            }
        };

        var getCurrentNodes = function (currentPage) {
            var itemsPerPage = $scope.tableConfig.itemsPerPage;
            var startIndex = (currentPage - 1) * itemsPerPage;
            var endIndex = currentPage * itemsPerPage;
            if (endIndex > $scope.nodesData.length) {
                endIndex = $scope.nodesData.length;
            }
            return $scope.nodesData.slice(startIndex, endIndex);
        };

        var initTableAttributes = function (attrs) {
            var res = {
                key: undefined,
                values: []
            };
            var len = attrs.length;
            var totalPercentage = 1.0;
            var leftPercentage = totalPercentage;
            var color = d3.scale.category10();
            for (var i = 0; i < len; i++) {
                if (attrs[i].name == 'name') {
                    res.key = attrs[i];
                    continue;
                }
                if (i != len - 1) {
                    attrs[i].percentage = totalPercentage / (len - 1);
                    leftPercentage -= attrs[i].percentage;
                } else {
                    attrs[i].percentage = leftPercentage;

                }
                attrs[i].color = color(i);
                //attrs[i].alias = attrs[i].name.slice(0, 1);
                attrs[i].show = true;
                res.values.push(attrs[i]);
            }
            return res;
        };

        $scope.highlightNode = function (node) {
            node.highlight = !node.highlight;
            //msg.rawIndex = node.rawIndex;
            dataService.setHighlightNode(node, node.highlight);
            pipService.emitHighlightChange(node);
        };
    }]);
