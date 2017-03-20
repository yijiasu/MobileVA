'use strict';

vishope.controller('task2TestCtrl', ['$scope', '$interval', 'pipService',
    'dataService', function($scope, $interval, pipService, dataService) {

        dataService.updateDataset('vis_graphic').then(function(promise) {
            $scope.nodeDict = initialSort(promise.data);
            $scope.qcnt = 0;
            $scope.tcnt = 0;
            $scope.maxT = 7;
            $scope.maxQ = 3;
        });

        $scope.maxTime = 60;
        $scope.timer = false;
        $scope.timeSt = undefined;
        $scope.timeEd = undefined;
        $scope.questionList = [
            [
            //Q1
            {
                'nameList': ['Xiaoou Tang'],
                'title': 'Which year does the ego has the largest number of neighbors between 2008 and 2012?',
                'choiceList': [2008, 2009, 2010, 2011, 2012],
                'answer': 2008,
                'index': 0
            },
            {
                'nameList': ['Kwan-Liu Ma'],
                'title': 'Which year does the ego has the largest number of neighbors between 2007 and 2011?',
                'choiceList': [2007, 2008, 2009, 2010, 2011],
                'answer': 2009,
                'index': 1
            },
            {
                'nameList': ['Daniel Cohen-Or'],
                'title': 'Which year does the ego has the largest number of neighbors between 2005 and 2009?',
                'choiceList': [2005, 2006, 2007, 2008, 2009],
                'answer': 2008,
                'index': 2
            },
            {
                'nameList': ['Harry Shum'],
                'title': 'Which year does the ego has the largest number of neighbors between 2001 and 2005?',
                'choiceList': [2001, 2002, 2003, 2004, 2005],
                'answer': 2005,
                'index': 3
            }
            ],
            //Q2
            [{
                'nameList': ['Xilin Chen'],
                'title': 'How many years does the ego\'s neighbor size increase between 2009 and 2013?',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 2,
                'index': 0
            },
            {
                'nameList': ['Hujun Bao'],
                'title': 'How many years does the ego\'s neighbor size increase between 2005 and 2009?',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 2,
                'index': 1
            },
            {
                'nameList': ['John T_ Stasko'],
                'title': 'How many years does the ego\'s neighbor size increase between 2009 and 2013?',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 2,
                'index': 2
            },
            {
                'nameList': ['Larry S_ Davis'],
                'title': 'How many years does the ego\'s neighbor size increase between 2010 and 2014?',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 1,
                'index': 3
            }
            ],
            //Q3
            [{
                'nameList': ['Kwan-Liu Ma'],
                'title': 'Which year does the highlighted neighbor have the strongest tie strength between 2008 and 2012?',
                'choiceList': [2008, 2009, 2010, 2011, 2012],
                'tieStrAlter': 'Carlos D_ Correa',
                'answer': 2010,
                'index': 0
            },
            {
                'nameList': ['Daniel Cohen-Or'],
                'title': 'Which year does the highlighted neighbor have the strongest tie strength between 2005 and 2009?',
                'choiceList': [2005, 2006, 2007, 2008, 2009],
                'tieStrAlter': 'Dani Lischinski',
                'answer': 2009,
                'index': 1
            },
            {
                'nameList': ['Andrew Zisserman'],
                'title': 'Which year does the highlighted neighbor have the strongest tie strength between 1992 and 1996?',
                'tieStrAlter': 'Charlie Rothwell',
                'choiceList': [1992, 1993, 1994, 1995, 1996],
                'answer': 1993,
                'index': 2
            },
            {
                'nameList': ['Shree K_ Nayar'],
                'title': 'Which year does the highlighted neighbor have the strongest tie strength between 2000 and 2004?',
                'choiceList': [2000, 2001, 2002, 2003, 2004],
                'tieStrAlter': 'Michael D_ Grossberg',
                'answer': 2001,
                'index': 3
            }
            ],
            //Q4
            [{
                'nameList': ['Ravin Balakrishnan'],
                'title': 'How many years does the highlighted neighbor\'s tie strength increase between 2003 and 2007?',
                'choiceList': [0, 1, 2, 3, 4],
                'tieStrAlter': 'Daniel Wigdor',
                'answer': 2,
                'index': 0
            },
            {
                'nameList': ['Hanspeter Pfister'],
                'title': 'How many years does the highlighted neighbor\'s tie strength increase between 2007 and 2011?',
                'choiceList': [0, 1, 2, 3, 4],
                'tieStrAlter': 'Wojciech Matusik',
                'answer': 1,
                'index': 1
            },
            {
                'nameList': ['Stefano Soatto'],
                'title': 'How many years does the highlighted neighbor\'s tie strength increase between 2001 and 2005?',
                'tieStrAlter': 'Paolo Favaro',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 1,
                'index': 2
            },
            {
                'nameList': ['Takeo Igarashi'],
                'title': 'How many years does the highlighted neighbor\'s tie strength increase between 2010 and 2014?',
                'choiceList': [0, 1, 2, 3, 4],
                'tieStrAlter': 'Masahiko Inami',
                'answer': 2,
                'index': 3
            }
            ],
            //Q5
            [{
                'nameList': ['Jitendra Malik'],
                'title': 'Which year does the ego has the largest number of connected components between 2005 and 2009?',
                'choiceList': [2005, 2006, 2007, 2008, 2009],
                'answer': 2009,
                'index': 0
            },
            {
                'nameList': ['Hans Hagen'],
                'title': 'Which year does the ego has the largest number of connected components between 2008 and 2012?',
                'choiceList': [2008, 2009, 2010, 2011, 2012],
                'answer': 2010,
                'index': 1
            },
            {
                'nameList': ['Maneesh Agrawala'],
                'title': 'Which year does the ego has the largest number of connected components between 2009 and 2013?',
                'choiceList': [2009, 2010, 2011, 2012, 2013],
                'answer': 2011,
                'index': 2
            },
            {
                'nameList': ['David S_ Ebert'],
                'title': 'Which year does the ego has the largest number of connected components between 2007 and 2011?',
                'choiceList': [2007, 2008, 2009, 2010, 2011],
                'answer': 2007,
                'index': 3
            }
            ],
            //Q6
            [{
                'nameList': ['Dieter Schmalstieg'],
                'title': 'How many years does the egonetwork\'s connected component number increase between 2010 and 2014?',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 1,
                'index': 0
            },
            {
                'nameList': ['Daniel Weiskopf'],
                'title': 'How many years does the egonetwork\'s connected component number increase between 2010 and 2014?',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 1,
                'index': 1
            },
            {
                'nameList': ['Roberto Cipolla'],
                'title': 'How many years does the egonetwork\'s connected component number increase between 2009 and 2013?',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 3,
                'index': 2
            },
            {
                'nameList': ['Pascal Fua'],
                'title': 'How many years does the egonetwork\'s connected component number increase between 2007 and 2011?',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 2,
                'index': 3
            }
            ],
            //Q7
            [{
                'nameList': ['Ramesh Raskar'],
                'title': 'Which year does the ego has the smallest percentage of new neighbors between 2005 and 2009?',
                'choiceList': [2005, 2006, 2007, 2008, 2009],
                'answer': 2006,
                'index': 0
            },
            {
                'nameList': ['Horst Bischof'],
                'title': 'Which year does the ego has the smallest percentage of new neighbors between 2009 and 2013?',
                'choiceList': [2009, 2010, 2011, 2012, 2013],
                'answer': 2013,
                'index': 1
            },
            {
                'nameList': ['Thomas Ertl'],
                'title': 'Which year does the ego has the smallest percentage of new neighbors between 2005 and 2009?',
                'choiceList': [2005, 2006, 2007, 2008, 2009],
                'answer': 2007,
                'index': 2
            },
            {
                'nameList': ['Harry Shum'],
                'title': 'Which year does the ego has the smallest percentage of new neighbors between 2006 and 2010?',
                'choiceList': [2006, 2007, 2008, 2009, 2010],
                'answer': 2010,
                'index': 3
            }
            ],
            //Q8
            [{
                'nameList': ['Valerio Pascucci'],
                'title': 'How many year does the percentage of new neighbors less than 50% between 2010 and 2014?',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 2,
                'index': 0
            },
            {
                'nameList': ['William Ribarsky'],
                'title': 'How many year does the percentage of new neighbors less than 50% between 2007 and 2011?',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 1,
                'index': 1
            },
            {
                'nameList': ['Hanspeter Pfister'],
                'title': 'How many year does the percentage of new neighbors less than 50% between 2005 and 2009?',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 1,
                'index': 2
            },
            {
                'nameList': ['Pat Hanrahan'],
                'title': 'How many year does the percentage of new neighbors less than 50% between 2001 and 2005?',
                'choiceList': [0, 1, 2, 3, 4],
                'answer': 2,
                'index': 3
            }
            ]
        ];

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

        for (var i = 0; i < $scope.questionList.length; i++) {
            $scope.questionList[i] = shuffle($scope.questionList[i]);
        }

        $scope.task2Skip = function() {
            $scope.timeEd = Date.now();
            $scope.timer = false;
            $interval.cancel($scope.countdown);
            var timespan = $scope.timeEd - $scope.timeSt;
            var flag;
            var question = $scope.questionList[$scope.tcnt][$scope.qcnt];
            if ($scope.selectedAnswer == $scope.correctAnswer) {
                flag = 1;
            } else {
                flag = 0;
            }
            var res = {};
            res['flag'] = flag;
            res['timespan'] = timespan;
            res['qNum'] = $scope.qcnt;
            res['tNum'] = $scope.tcnt;
            res['index'] = question['index'];
            if ($scope.selectedAnswer) {
                res['useranswer'] = $scope.selectedAnswer;
            } else {
                res['useranswer'] = 'null';
            }
            res['skip'] = 1;
            //console.log(res);
            dataService.recordTask2(res);
            $scope.qcnt++;
            if ($scope.qcnt == $scope.maxQ + 1 && $scope.tcnt == $scope.maxT) {
                window.setTimeout(function() {
                    $.get('./task2finish', function() {
                        window.location = './userstudy_main';
                    });
                }, 2000);
            }
        };

        $scope.task2Next = function() {
            $scope.timeEd = Date.now();
            $scope.timer = false;
            $interval.cancel($scope.countdown);
            var timespan = $scope.timeEd - $scope.timeSt;
            var flag;
            var question = $scope.questionList[$scope.tcnt][$scope.qcnt];
            if ($scope.selectedAnswer == $scope.correctAnswer) {
                flag = 1;
            } else {
                flag = 0;
            }
            var res = {};
            res['flag'] = flag;
            res['timespan'] = timespan;
            res['qNum'] = $scope.qcnt;
            res['tNum'] = $scope.tcnt;
            res['index'] = question['index'];
            if ($scope.selectedAnswer) {
                res['useranswer'] = $scope.selectedAnswer;
            } else {
                res['useranswer'] = 'null';
            }
            res['skip'] = 0;
            //console.log(res);
            dataService.recordTask2(res);
            $scope.qcnt++;
            if ($scope.qcnt == $scope.maxQ + 1 && $scope.tcnt == $scope.maxT) {
                window.setTimeout(function() {
                    $.get('./task2finish', function() {
                        window.location = './userstudy_main';
                    });
                }, 2000);

            }
        };

        $scope.task2Display = function() {
            $scope.hiddenFlag = false;
            $scope.choiceList = $scope.questionList[$scope.tcnt][$scope.qcnt]['choiceList'];
            $scope.selectedAnswer = undefined;
            if (!$scope.timer) {
                $scope.timer = true;
                $scope.timeSt = Date.now();
                $scope.remainTime = $scope.maxTime;
                $scope.countdown = $interval(function() {
                    $scope.remainTime -= 1;
                    if ($scope.remainTime == 0) {
                        $scope.task2Next();
                    }
                }, 1000);
            }
        };

        //$scope.$watch('tcnt', function(newVal, oldVal) {
            //$scope.choiceList = $scope.choiceListList[newVal];
        //});

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
                    $scope.hiddenFlag = true;
                    $scope.correctAnswer = $scope.questionList[$scope.tcnt][$scope.qcnt]['answer'];
                    $scope.choiceList = [];
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
                        var nameList = $scope.questionList[$scope.tcnt][newVal]['nameList'];
                        for (var i = 0; i < nameList.length; i++) {
                            var node = $scope.nodeDict[nameList[i]];
                            if ($scope.tcnt == 2) {
                                node['tieStrAlter'] = $scope.questionList[$scope.tcnt][newVal]['tieStrAlter'];
                            } else if ($scope.tcnt == 3) {
                                node['tieStrAlter'] = $scope.questionList[$scope.tcnt][newVal]['tieStrAlter'];
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
                        var nameList = $scope.questionList[$scope.tcnt][newVal]['nameList'];
                        for (var i = 0; i < nameList.length; i++) {
                            var node = $scope.nodeDict[nameList[i]];
                            if ($scope.tcnt == 2) {
                                node['tieStrAlter'] = $scope.questionList[$scope.tcnt][newVal]['tieStrAlter'];
                            } else if ($scope.tcnt == 3) {
                                node['tieStrAlter'] = $scope.questionList[$scope.tcnt][newVal]['tieStrAlter'];
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
    }]);
