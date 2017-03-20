'use strict';

vishope.controller('task1TestCtrl', ['$scope', '$interval', 'pipService',
    'dataService', function($scope, $interval, pipService, dataService) {

        dataService.updateDataset('vis_graphic').then(function(promise) {
            $scope.nodeDict = initialSort(promise.data);
            $scope.qcnt = 0;
            $scope.tcnt = 0;
            $scope.maxT = 3;
            $scope.maxQ = 3;
        });

        $scope.maxTime = 60;
        $scope.timer = false;
        $scope.timeSt = undefined;
        $scope.timeEd = undefined;
        $scope.questionList = [
            [{
                'nameList': ['Yoichi Sato', 'Michelle X_ Zhou', 'Yasushi Yagi', 'Stefano Soatto', 'Trevor Darrell'],
                'title': 'How many ego\'s neighbor size keep increasing between 2011 and 2013?',
                'choiceList': [1, 2, 3, 4, 5],
                'answer': 1,
                'index': 0
            },
            {
                'nameList': ['Christoph Garth', 'Hanspeter Pfister', 'Dieter Schmalstieg', 'Steven M_ Seitz', 'Stefano Soatto'],
                'title': 'How many ego\'s neighbor size keep increasing between 2010 and 2012?',
                'choiceList': [1, 2, 3, 4, 5],
                'answer': 2,
                'index': 1
            },
            {
                'nameList': ['Maneesh Agrawala', 'Xiaoou Tang', 'Marc Pollefeys' , 'Markus Hadwiger', 'Markus H_ Gross'],
                'title': 'How many ego\'s neighbor size keep increasing between 2008 and 2010?',
                'choiceList': [1, 2, 3, 4, 5],
                'answer': 1,
                'index': 2
            },
            {
                'nameList': ['Pat Hanrahan', 'Markus H_ Gross', 'John T_ Stasko', 'Shree K_ Nayar', 'Anil K_ Jain'],
                'title': 'How many ego\'s neighbor size keep increasing between 2006 and 2008?',
                'choiceList': [1, 2, 3, 4, 5],
                'answer': 2,
                'index': 3
            }],
            [{
                'nameList': ['Dimitris N_ Metaxas', 'Trevor Darrell', 'Cordelia Schmid', 'Rama Chellappa', 'Maneesh Agrawala'],
                'title': 'Which ego has the largest number of common neighbors between 2011 and 2012?',
                'choiceList': ['Dimitris N_ Metaxas', 'Trevor Darrell', 'Cordelia Schmid', 'Rama Chellappa', 'Maneesh Agrawala'],
                'answer': 'Maneesh Agrawala',
                'index': 0
            },
            {
                'nameList': ['Valerio Pascucci', 'William Ribarsky', 'Steven M_ Seitz', 'Helwig Hauser', 'Daniel Cremers'],
                'title': 'Which ego has the largest number of common neighbors between 2008 and 2009?',
                'choiceList': ['Valerio Pascucci', 'William Ribarsky', 'Steven M_ Seitz', 'Helwig Hauser', 'Daniel Cremers'],
                'answer': 'William Ribarsky',
                'index': 1
            },
            {
                'nameList': ['Ravi Ramamoorthi', 'Katsushi Ikeuchi', 'Martial Hebert', 'Kenneth I_ Joy', 'Pietro Perona'],
                'choiceList': ['Ravi Ramamoorthi', 'Katsushi Ikeuchi', 'Martial Hebert', 'Kenneth I_ Joy', 'Pietro Perona'],
                'title': 'Which ego has the largest number of common neighbors between 2008 and 2009?',
                'answer': 'Ravi Ramamoorthi',
                'index': 2
            },
            {
                'nameList': ['Pat Hanrahan', 'Daniel A_ Keim', 'Trevor Darrell', 'Dinesh Manocha', 'Hans Hagen'],
                'choiceList': ['Pat Hanrahan', 'Daniel A_ Keim', 'Trevor Darrell', 'Dinesh Manocha', 'Hans Hagen'],
                'title': 'Which ego has the largest number of common neighbors between 2009 and 2010?',
                'answer': 'Daniel A_ Keim',
                'index': 3
            }],
            [{
                'nameList': ['Kwan-Liu Ma', 'Edwin R_ Hancock', 'Harry Shum', 'Andrew Zisserman', 'Larry S_ Davis'],
                'choiceList': ['Kwan-Liu Ma', 'Edwin R_ Hancock', 'Harry Shum', 'Andrew Zisserman', 'Larry S_ Davis'],
                'title': 'Which ego has the largest number of neighbors at 2005?',
                'answer': 'Harry Shum',
                'index': 0
            },
            {
                'nameList': ['Mubarak Shah', 'Tieniu Tan', 'Marc Pollefeys', 'Arie E_ Kaufman', 'Takeo Igarashi'],
                'choiceList': ['Mubarak Shah', 'Tieniu Tan', 'Marc Pollefeys', 'Arie E_ Kaufman', 'Takeo Igarashi'],
                'title': 'Which ego has the largest number of neighbors at 2008?',
                'answer': 'Marc Pollefeys',
                'index': 1
            },
            {
                'nameList': ['Brad A_ Myers', 'Bernd Hamann', 'Scott E_ Hudson', 'Maneesh Agrawala', 'Arie E_ Kaufman'],
                'choiceList': ['Brad A_ Myers', 'Bernd Hamann', 'Scott E_ Hudson', 'Maneesh Agrawala', 'Arie E_ Kaufman'],
                'title': 'Which ego has the largest number of neighbors at 2010?',
                'answer': 'Brad A_ Myers',
                'index': 2
            },
            {
                'nameList': ['Stan Z_ Li', 'Ying Wu', 'Stephen Lin', 'Klaus Mueller', 'Sing Bing Kang'],
                'choiceList': ['Stan Z_ Li', 'Ying Wu', 'Stephen Lin', 'Klaus Mueller', 'Sing Bing Kang'],
                'title': 'Which ego has the largest number of neighbors at 2008',
                'answer': 'Stephen Lin',
                'index': 3
            }],
            [{
                'nameList': ['Daniel Cohen-Or', 'Andrew Zisserman', 'Kwan-Liu Ma', 'Harry Shum', 'Larry S_ Davis'],
                'choiceList': ['Daniel Cohen-Or', 'Andrew Zisserman', 'Kwan-Liu Ma', 'Harry Shum', 'Larry S_ Davis'],
                'title': 'Which ego has the smallest percentage of new neighbors at 2007?',
                'answer': 'Kwan-Liu Ma',
                'index': 0
            },
            {
                'nameList': ['Hans Hagen', 'Maneesh Agrawala', 'Roberto Cipolla', 'Rama Chellappa', 'Jitendra Malik'],
                'choiceList': ['Hans Hagen', 'Maneesh Agrawala', 'Roberto Cipolla', 'Rama Chellappa', 'Jitendra Malik'],
                'title': 'Which ego has the smallest percentage of new neighbors at 2005?',
                'answer': 'Jitendra Malik',
                'index': 1
            },
            {
                'nameList': ['Gerik Scheuermann', 'Ming C_ Lin', 'Xilin Chen', 'Kun Zhou', 'Nikos Paragios'],
                'choiceList': ['Gerik Scheuermann', 'Ming C_ Lin', 'Xilin Chen', 'Kun Zhou', 'Nikos Paragios'],
                'title': 'Which ego has the smallest percentage of new neighbors at 2009?',
                'answer': 'Xilin Chen',
                'index': 2
            },
            {
                'nameList': ['Holger Theisel', 'Jean Ponce', 'Steven M_ Seitz', 'Sing Bing Kang', 'Klaus Mueller'],
                'choiceList': ['Holger Theisel', 'Jean Ponce', 'Steven M_ Seitz', 'Sing Bing Kang', 'Klaus Mueller'],
                'title': 'Which ego has the smallest percentage of new neighbors at 2010?',
                'answer': 'Holger Theisel',
                'index': 3
            }]
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

        $scope.task1Skip = function() {
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
            dataService.recordTask1(res);
            $scope.qcnt++;
            if ($scope.qcnt == $scope.maxQ + 1 && $scope.tcnt == $scope.maxT) {
                window.setTimeout(function() {
                    $.get('./task1finish', function() {
                        window.location = './userstudy_main';
                    });
                }, 2000);
            }
        };

        $scope.task1Next = function() {
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
            dataService.recordTask1(res);
            $scope.qcnt++;
            if ($scope.qcnt == $scope.maxQ + 1 && $scope.tcnt == $scope.maxT) {
                window.setTimeout(function() {
                    $.get('./task1finish', function() {
                        window.location = './userstudy_main';
                    });
                }, 2000);

            }
        };

        $scope.task1Display = function() {
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
                        $scope.task1Next();
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
                            if ($scope.tcnt == 1) {
                                node['constantEgoFlag'] = true;
                                console.log(node);
                            } else {
                                node['constantEgoFlag'] = false;
                            }
                            if ($scope.tcnt == 3) {
                                node['newAlter'] = true;
                                console.log(node);
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
                nodes[name].rect = false;
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
