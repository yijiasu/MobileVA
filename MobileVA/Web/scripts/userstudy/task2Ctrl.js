'use strict';

vishope.controller('task2Ctrl', ['$scope', 'pipService',
    'dataService', 'baselineService', function($scope, pipService, dataService, baselineService) {

        dataService.updateDataset('vis_graphic').then(function(promise) {
            $scope.nodeDict = initialSort(promise.data);
            $scope.qcnt = 0;
            $scope.tcnt = 0;
            $scope.maxT = 7;
            $scope.maxQ = 1;
        });
        $scope.nameList = [
            [['Kwan-Liu Ma'],['Kwan-Liu Ma']],
            [['Larry S_ Davis'], ['Larry S_ Davis']],
            [['Kwan-Liu Ma'],['Xiaoou Tang']],
            [['Markus H_ Gross'], ['Markus H_ Gross']],
            [['Kwan-Liu Ma'],['Xiaoou Tang']],
            [['Larry S_ Davis'], ['Larry S_ Davis']],
            [['Kwan-Liu Ma'],['Xiaoou Tang']],
            [['Larry S_ Davis'], ['Larry S_ Davis']],
        ];

        $scope.titleList = [
            'Which year does the ego has the largest number of neighbors between 2006 and 2010?',
            'How many years does the ego\'s neighbor size increase between 2010 and 2014?',
            'Which year does the highlighted neighbor have the strongest tie strength between 2006 and 2010?',
            'How many years does the highlighted neighbor\'s tie strength increase between 2010 and 2014?',
            'Which year does the ego has the largest number of connected components between 2006 and 2010?',
            'How many years does the egonetwork\'s connected component number increase between 2010 and 2014?',
            'Which year does the ego has the smallest percentage of new neighbors between 2006 and 2010?',
            'How many year does the percentage of new neighbors less than 50% between 2010 and 2014?'
        ];

        $scope.choiceListList = [
            [2006, 2007, 2008, 2009, 2010],
            [0, 1, 2, 3, 4],
            [2006, 2007, 2008, 2009, 2010],
            [0, 1, 2, 3, 4],
            [2006, 2007, 2008, 2009, 2010],
            [0, 1, 2, 3, 4],
            [2006, 2007, 2008, 2009, 2010],
            [0, 1, 2, 3, 4]
        ];

        $scope.answerList = [
            [2009, 2009],
            [1, 1],
            [2009, 2009],
            [2, 2],
            [2007, 2007],
            [2, 2],
            [2007, 2007],
            [1, 1]
        ];

        $scope.task2Next = function() {
            if ($scope.qcnt == $scope.maxQ && $scope.tcnt == $scope.maxT) {
                window.location = './task2test';
            } else {
                if ($scope.qcnt == 0) {
                    $('#task2-back').html('Previous');
                }
                $scope.qcnt++;
                if ($scope.qcnt == $scope.maxQ && $scope.tcnt == $scope.maxT) {
                    $('#task2-next').html('Go to Test');
                }
            }
        };
        $scope.task2Back = function() {
            if ($scope.qcnt == 0 && $scope.tcnt == 0) {
                window.location = './userstudy_main';
            } else {
                if ($scope.qcnt == $scope.maxQ) {
                    $('#task2-next').html('Next');
                }
                $scope.qcnt--;
                if ($scope.qcnt == 0 && $scope.tcnt == 0) {
                    $('#task2-back').html('Go back');
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
                        //baselineService.clearEgoList();
                        var nameList = $scope.nameList[$scope.tcnt][newVal];
                        for (var i = 0; i < nameList.length; i++) {
                            var node = $scope.nodeDict[nameList[i]];
                            if ($scope.tcnt == 2) {
                                node['tieStrAlter'] = 'Chris Muelder';
                            } else if ($scope.tcnt == 3) {
                                node['tieStrAlter'] = 'Robert W_ Sumner';
                            } else {
                                node['tieStrAlter'] = undefined;
                            }
                            if ($scope.tcnt == 4 || $scope.tcnt == 5) {
                                node['connectedComponents'] = true;
                            } else {
                                node['connectedComponents'] = false;
                            }
                            if ($scope.tcnt == 6 || $scope.tcnt == 7) {
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
                            if ($scope.tcnt == 2) {
                                node['tieStrAlter'] = 'Chris Muelder';
                            } else if ($scope.tcnt == 3) {
                                node['tieStrAlter'] = 'Robert W_ Sumner';
                            } else {
                                node['tieStrAlter'] = undefined;
                            }
                            $scope.highlightNode(node);
                            pipService.emitExpand(node);
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
