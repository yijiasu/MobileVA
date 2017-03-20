'use strict';

vishope.controller('task1Ctrl', ['$scope', 'pipService',
    'dataService', function($scope, pipService, dataService) {

        dataService.updateDataset('vis_graphic').then(function(promise) {
            $scope.nodeDict = initialSort(promise.data);
            $scope.qcnt = 0;
            $scope.tcnt = 0;
            $scope.maxT = 3;
            $scope.maxQ = 1;
        });
        $scope.nameList = [
            [['Elizabeth D_ Mynatt', 'Huamin Qu', 'Daniel A_ Keim', 'Wen Gao', 'Hujun Bao'],
            ['Elizabeth D_ Mynatt', 'Huamin Qu', 'Daniel A_ Keim', 'Wen Gao', 'Hujun Bao']],
            [['Pat Hanrahan', 'Trevor Darrell', 'Roberto Cipolla', 'Baining Guo', 'Tieniu Tan'],
            ['Pat Hanrahan', 'Trevor Darrell', 'Roberto Cipolla', 'Baining Guo', 'Tieniu Tan']],
            [['Elizabeth D_ Mynatt', 'Huamin Qu', 'Daniel A_ Keim', 'Wen Gao', 'Hujun Bao'],
            ['Elizabeth D_ Mynatt', 'Huamin Qu', 'Daniel A_ Keim', 'Wen Gao', 'Hujun Bao']],
            [['Pat Hanrahan', 'Trevor Darrell', 'Roberto Cipolla', 'Baining Guo', 'Tieniu Tan'],
            ['Pat Hanrahan', 'Trevor Darrell', 'Roberto Cipolla', 'Baining Guo', 'Tieniu Tan']],
        ];

        $scope.titleList = [
            'How many ego\'s neighbor size keep increasing between 2005 and 2007?',
            'Which ego has the largest number of common neighbors between 2007 and 2008?',
            'Which ego has the largest number of neighbors at 2007?',
            'Which ego has the smallest percentage of new neighbors at 2007?'
        ];

        $scope.choiceListList = [
            [1, 2, 3, 4, 5],
            ['Pat Hanrahan', 'Trevor Darrell', 'Roberto Cipolla', 'Baining Guo', 'Tieniu Tan'],
            ['Elizabeth D_ Mynatt', 'Huamin Qu', 'Daniel A_ Keim', 'Wen Gao', 'Hujun Bao'],
            ['Pat Hanrahan', 'Trevor Darrell', 'Roberto Cipolla', 'Baining Guo', 'Tieniu Tan']
        ];

        $scope.answerList = [
            [1, 1],
            ['Baining Guo', 'Baining Guo'],
            ['Daniel A_ Keim', 'Daniel A_ Keim'],
            ['Roberto Cipolla', 'Roberto Cipolla']
        ];

        $scope.task1Next = function() {
            if ($scope.qcnt == $scope.maxQ && $scope.tcnt == $scope.maxT) {
                window.location = './task1test';
            } else {
                if ($scope.qcnt == 0) {
                    $('#task1-back').html('Previous');
                }
                $scope.qcnt++;
                if ($scope.qcnt == $scope.maxQ && $scope.tcnt == $scope.maxT) {
                    $('#task1-next').html('Go to Test');
                }
            }
        };
        $scope.task1Back = function() {
            if ($scope.qcnt == 0 && $scope.tcnt == 0) {
                window.location = './userstudy_main';
            } else {
                if ($scope.qcnt == $scope.maxQ) {
                    $('#task1-next').html('Next');
                }
                $scope.qcnt--;
                if ($scope.qcnt == 0 && $scope.tcnt == 0) {
                    $('#task1-back').html('Go back');
                }
            }
        };

        $scope.$watch('tcnt', function(newVal, oldVal) {
            $scope.choiceList = $scope.choiceListList[newVal];
        });

        $scope.$watch('qcnt', function(newVal, oldVal) {
            if (newVal == -1) {
                if ($scope.tcnt != 0) {
                    $scope.qcnt = $scope.maxQ;
                    $scope.tcnt -= 1;
                }
            } else if (newVal == $scope.maxQ + 1) {
                if ($scope.tcnt != $scope.maxT) {
                    $scope.tcnt += 1;
                    $scope.qcnt = 0;
                }
            } else {
                if (newVal != undefined) {
                    $scope.selectedAnswer = undefined;
                    $scope.correctAnswer = $scope.answerList[$scope.tcnt][$scope.qcnt];
                    $('.synScroll').animate({
                        scrollLeft: 0
                    }, 0);
                    $('#timelineTop').animate({
                        scrollLeft: 0
                    }, 0);
                    $('#timelineTop2').animate({
                        scrollLeft: 0
                    }, 0);
                    if (newVal % 2 != 0) {
                        pipService.emitClearEgoBSList();
                        var nameList = $scope.nameList[$scope.tcnt][newVal];
                        for (var i = 0; i < nameList.length; i++) {
                            var node = $scope.nodeDict[nameList[i]];
                            if ($scope.tcnt == 1) {
                                node['constantEgoFlag'] = true;
                            } else {
                                node['constantEgoFlag'] = false;
                            }
                            if ($scope.tcnt == 3) {
                                node['newAlter'] = true;
                            } else {
                                node['newAlter'] = false;
                            }
                            $scope.highlightBSNode(node);
                        }
                    } else {
                        pipService.emitClearEgoList();
                        var nameList = $scope.nameList[$scope.tcnt][newVal];
                        for (var i = 0; i < nameList.length; i++) {
                            var node = $scope.nodeDict[nameList[i]];
                            $scope.highlightNode(node);
                        }
                    }
                }
            }
        });

        $scope.highlightBSNode = function(node) {
            node.highlight = true;
            //dataService.setHighlightNode(node, node.highlight);
            pipService.emitHighlightBSChange(node);
        };

        $scope.highlightNode = function(node) {
            node.highlight = true;
            //dataService.setHighlightNode(node, node.highlight);
            pipService.emitHighlightChange(node);
        };

        var initialSort = function(dataset) {
            var nodes = {};
            for (var i = 0; i < dataset.length; i++) {
                var name = dataset[i]['id'];
                nodes[name] = {};
                nodes[name].id = dataset[i]['id'];
                nodes[name].neighbors = dataset[i]['neighbors'];
                nodes[name].allNeighborDict = dataset[i]['allNeighborDict'];
                nodes[name].yearDict = dataset[i]['yearDict'];
                nodes[name].filterRange = genFilterRange(dataset[i]['allNeighborDict']);
                nodes[name].startYear = dataset[i]['startYear'];
                nodes[name].endYear = dataset[i]['endYear'];
                nodes[name].neighborLen = dataset[i]['neighborLen'];
                nodes[name].publication = dataset[i]['publication'];
                nodes[name].name = dataset[i]['name'];
                nodes[name].highlight = false;
                nodes[name].synScroll = true;
                nodes[name].performanceFlag = false;
            }
            return nodes;
        };

        var genFilterRange = function(dict) {
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
        var shuffle = function(array) {
          var currentIndex = array.length, temporaryValue, randomIndex;
          while (0 !== currentIndex) {

              randomIndex = Math.floor(Math.random() * currentIndex);
              currentIndex -= 1;

              temporaryValue = array[currentIndex];
              array[currentIndex] = array[randomIndex];
              array[randomIndex] = temporaryValue;
          }

          return array;
        };
    }]);
