'use strict';

vishope.factory('baselineService', ['$http', 'dataService',
        function($http, dataService) {
    var baselineService = {
        basicHeight: 100,
        basicOffset: 10
    };

    var calLog = function(x, y) {
        return Math.log(x) / Math.log(y);
    };

    var updateTimelineCanvas = function() {
        //d3.select('#timelineZone').select('svg').data([]).exit().remove();
        var timelineConfig = baselineService.timelineConfig;
        var yearList = genFullYearList(timelineConfig.startYear, timelineConfig.endYear);
        var timelineCanvas = d3.select('#timelineCanvasBS');

        timelineCanvas
            .attr('width', timelineConfig.width);

        if (timelineCanvas.selectAll('.timelineLabel').empty()) {
            timelineCanvas.selectAll('.timelineLabel')
                .data(yearList)
                .enter()
                .append('text')
                .attr('class', 'timelineLabel')
                .attr('x', function(d) {
                    return genYearDistance(timelineConfig.startYear, d) * 100 + timelineConfig.basicWidth / 2;
                })
                .attr('y', 30)
                .attr('dx', -16)
                .text(function(d) {
                    return d;
                });
            timelineCanvas.selectAll('.timelineBar')
                .data(yearList)
                .enter()
                .append('line')
                .attr('class', 'timelineBar')
                .attr('x1', function(d) {
                    return genYearDistance(timelineConfig.startYear, d) * 100 + timelineConfig.basicWidth / 2;
                })
                .attr('y1', 35)
                .attr('x2', function(d) {
                    return genYearDistance(timelineConfig.startYear, d) * 100 + timelineConfig.basicWidth / 2;
                })
                .attr('y2', 40)
                .style('stroke', 'black')
                .style('stroke-width', 2);
        } else {
            var timelineLabel = timelineCanvas.selectAll('.timelineLabel')
                .data(yearList, function(d) {
                    return d;
                });
            timelineLabel.transition()
                .duration(800)
                .attr('x', function(d) {
                    return genYearDistance(timelineConfig.startYear, d) * 100 +
                        timelineConfig.basicWidth / 2;
                })
                .text(function(d) {
                    return d;
                });
            setTimeout(function() {
                timelineLabel.enter()
                    .append('text')
                    .attr('class', 'timelineLabel')
                    .attr('x', function(d) {
                        return genYearDistance(timelineConfig.startYear, d) * 100 +
                            timelineConfig.basicWidth / 2;
                    })
                    .attr('y', 30)
                    .attr('dx', -16)
                    .text(function(d) {
                        return d;
                    });
            }, 800);
            timelineLabel.exit().remove();

            var timelineBar = timelineCanvas.selectAll('.timelineBar')
                .data(yearList, function(d) {
                    return d;
                });
            timelineBar.transition()
                .duration(800)
                .attr('x1', function(d) {
                    return genYearDistance(timelineConfig.startYear, d) * 100 +
                        timelineConfig.basicWidth / 2;
                })
                .attr('x2', function(d) {
                    return genYearDistance(timelineConfig.startYear, d) * 100 +
                        timelineConfig.basicWidth / 2;
                });
            setTimeout(function() {
                timelineBar.enter()
                    .append('line')
                    .attr('class', 'timelineBar')
                    .attr('x1', function(d) {
                        return genYearDistance(timelineConfig.startYear, d) * 100 +
                            timelineConfig.basicWidth / 2;
                    })
                    .attr('y1', 35)
                    .attr('x2', function(d) {
                        return genYearDistance(timelineConfig.startYear, d) * 100 +
                            timelineConfig.basicWidth / 2;
                    })
                    .attr('y2', 40)
                    .style('stroke', 'black')
                    .style('stroke-width', 2);
            }, 800);
            timelineBar.exit().remove();
        }
    };

    var updateEgoGlyph = function() {
        var timelineConfig = baselineService.timelineConfig;
        d3.selectAll('.egoGlyphCanvas')
            .attr('width', timelineConfig.width);
        d3.selectAll('.egoGlyphWrapper')
            .transition()
            .duration(800)
            .attr('transform', function(d) {
                if (timelineConfig.startYear == undefined) {
                    return 'translate(0, 0)';
                }
                return 'translate(' + genYearDistance(timelineConfig.startYear, d.startYear) * 100 + ', 0)';
            });

    };

    baselineService.updateTimeline = function(timelineConfig) {
        this.timelineConfig = timelineConfig;
        updateTimelineCanvas();
        updateEgoGlyph();
    };

    baselineService.drawEgoBaseline = function(element, egoData) {
        var timelineConfig = baselineService.timelineConfig;
        d3.select(element).select('svg').data([]).remove().exit();
        var egoBaselineCanvas = d3.select(element)
            .append('svg')
            .attr('class', 'egoBaselineCanvas')
            .attr('width', timelineConfig.width)
            .attr('height', timelineConfig.basicWidth)
            .style('background', baselineService.backgroundColor);
        var egoBaselineWrapper = egoBaselineCanvas.selectAll('.egoBaselineWrapper')
            .data([egoData])
            .enter()
            .append('g')
            .attr('class', 'egoBaselineWrapper')
            .attr('transform', function(d) {
                return 'translate(' + genYearDistance(timelineConfig.startYear, d.startYear) * 100 + ', 0)';
            });
        drawEgoSpring(egoBaselineWrapper, egoData);
    };

    var drawEgoSpring = function(egoBaselineWrapper, egoData) {
        var timelineConfig = baselineService.timelineConfig;
        var yearList = genYearList(egoData['yearDict']);
        var alterYearStrDict = genAlterYearStrDict(egoData['yearDict']);
        var egoSpringWrapper = egoBaselineWrapper
            .append('g')
            .attr('class', 'egoSpringWrapper')
            .attr('transform', function(d) {
                return 'translate(' + (genYearDistance(egoData.startYear, egoData.startYear) * 100 + timelineConfig.basicWidth / 2) + ',' +
                    (timelineConfig.basicWidth / 2) + ')';
            });

        for (var i = 0; i < yearList.length; i++) {
            var nodes = [];
            var neighbors = egoData['yearDict'][yearList[i]]['neighborList'];
            for (var j = 0; j < neighbors.length; j++) {
                nodes.push(neighbors[j]);
            }
            var edges = [];
            var neighborEdges = egoData['yearDict'][yearList[i]]['edgeList'];
            for (var j = 0; j < neighborEdges.length; j++) {
                edges.push(neighborEdges[j]);
            }
            if (!egoData['connectedComponents']) {
                nodes.push(egoData['id']);
                for (var j = 0; j < nodes.length - 1; j++) {
                    edges.push({'index1': nodes.length - 1, 'index2': j});
                }
            }
            if (egoData['tieStrAlter'] != undefined) {
                edges = [];
                for (var j = 0; j < nodes.length - 1; j++) {
                    var tieStrength = egoData['yearDict'][yearList[i]]['tieStrength'][nodes[j]];
                    edges.push({'index1': nodes.length - 1, 'index2': j, 'value': tieStrength});
                }
            }
            var posDict = scalePos(egoData['yearDict'][yearList[i]]['pos']);

            egoBaselineWrapper
                .append('line')
                .attr('class', 'baselienSplitBar')
                .attr('x1', function(d) {
                    var cx = genYearDistance(egoData.startYear, yearList[i]) * 100;
                    return cx;
                })
                .attr('x2', function(d) {
                    var cx = genYearDistance(egoData.startYear, yearList[i]) * 100;
                    return cx;
                })
                .attr('y1', function(d) {
                    return 0;
                })
                .attr('y2', function(d) {
                    return 100;
                })
                .attr('stroke', '#eeeeee')
                .attr('stroke-width', 1);

            egoBaselineWrapper
                .append('line')
                .attr('class', 'baselienSplitBar')
                .attr('x1', function(d) {
                    var cx = genYearDistance(egoData.startYear, yearList[i]) * 100;
                    return cx + 100;
                })
                .attr('x2', function(d) {
                    var cx = genYearDistance(egoData.startYear, yearList[i]) * 100;
                    return cx + 100;
                })
                .attr('y1', function(d) {
                    return 0;
                })
                .attr('y2', function(d) {
                    return 100;
                })
                .attr('stroke', '#eeeeee')
                .attr('stroke-width', 1);

            var tip = d3.tip()
                .attr('class', 'd3-tip')
                .offset([10, 0])
                .direction('s')
                .html(function(d) {
                    var str = '<div id="myD3Tip"><ul>';
                    var atomStr = '<li>' + d + '</li>';
                    str += atomStr;
                    str += '</ul></div>';
                    return str;
                });
            egoBaselineWrapper.call(tip);
            egoBaselineWrapper.selectAll('.baselineEdge' + yearList[i])
                .data(edges)
                .enter()
                .append('line')
                .attr('class', 'baselineEdge' + yearList[i])
                .attr('x1', function(d) {
                    var cx = genYearDistance(egoData.startYear, yearList[i]) * 100;
                    var nodeID = nodes[d['index1']];
                    return cx + posDict[nodeID][0];
                })
                .attr('x2', function(d) {
                    var cx = genYearDistance(egoData.startYear, yearList[i]) * 100;
                    var nodeID = nodes[d['index2']];
                    return cx + posDict[nodeID][0];
                })
                .attr('y1', function(d) {
                    var nodeID = nodes[d['index1']];
                    return posDict[nodeID][1];
                })
                .attr('y2', function(d) {
                    var nodeID = nodes[d['index2']];
                    return posDict[nodeID][1];
                })
                .attr('stroke', function(d) {
                    var nodeID1 = nodes[d['index1']];
                    var nodeID2 = nodes[d['index2']];
                    if (egoData['tieStrAlter'] == nodeID1 || egoData['tieStrAlter'] == nodeID2) {
                        return '#80b1d3';
                    } else {
                        return '#aaaaaa';
                    }
                })
                .attr('stroke-width', function(d) {
                    if (egoData['tieStrAlter'] != undefined) {
                        return d.value *1.5;
                    } else {
                        return 1*1.5;
                    }
                });

            egoBaselineWrapper.selectAll('.baselineNode' + yearList[i])
                .data(nodes)
                .enter()
                .append('circle')
                .attr('class', 'baselineNode' + yearList[i])
                .attr('cx', function(d) {
                    var cx = genYearDistance(egoData.startYear, yearList[i]) * 100;
                    return cx + posDict[d][0];
                })
                .attr('cy', function(d) {
                    return posDict[d][1];
                })
                .attr('r', function(d) {
                    if (d == egoData['tieStrAlter']) {
                        return 4;
                    }
                    if (egoData['tieStrAlter'] == d) {
                        return 4;
                    }
                    if (egoData['constantEgoFlag'] == true && i != 0) {
                        if (egoData['yearDict'][yearList[i - 1]]['tieStrength'].hasOwnProperty(d)) {
                            return 4;
                        }
                    }
                    if (egoData['newAlter'] == true) {
                        if (d != egoData['id']) {
                            for (var k = 0; k < alterYearStrDict[d].length; k++) {
                                if (parseInt(alterYearStrDict[d][k]['year']) == yearList[i]) {
                                    if (k == 0) {
                                        return 4;
                                    } else {
                                        return 2;
                                    }
                                }
                            }
                        }
                    }
                    return 2;
                })
                .attr('fill', function(d) {
                    if (d == egoData['id']) {
                        return '#fb8072';
                    } else {
                        if (egoData['constantEgoFlag'] == true && i != 0) {
                            if (egoData['yearDict'][yearList[i - 1]]['tieStrength'].hasOwnProperty(d)) {
                                return '#80b1d3';
                            }
                        }
                        if (egoData['tieStrAlter'] == d) {
                            return '#80b1d3';
                        }
                        if (egoData['newAlter'] == true) {
                            if (d != egoData['id']) {
                                for (var k = 0; k < alterYearStrDict[d].length; k++) {
                                    if (parseInt(alterYearStrDict[d][k]['year']) == yearList[i]) {
                                        if (k == 0) {
                                            return '#80b1d3';
                                        } else {
                                            return '#999999';
                                        }
                                    }
                                }
                            }
                        }
                        return '#999999';
                    }
                })
                .on('mouseover', tip.show)
                .on('mouseout', tip.hide);
        }

    };

    var genAlterYearStrDict = function(yearDict) {
        var res = {};
        var yearList = genYearList(yearDict);
        for (var i = 0; i < yearList.length; i++) {
            var curDict = yearDict[yearList[i]]['tieStrength'];
            for (var key in curDict) {
                if (curDict.hasOwnProperty(key)) {
                    if (!res.hasOwnProperty(key)) {
                        res[key] = [];
                    }
                }
                res[key].push({'year': yearList[i], 'str': curDict[key]});
            }
        }
        return res;
    };

    var scalePos = function(yearNodePos) {
        var maxX = undefined;
        var minX = undefined;
        var maxY = undefined;
        var minY = undefined;
        for (var key in yearNodePos) {
            if (yearNodePos.hasOwnProperty(key)) {
                var author = yearNodePos[key];
                var x = author[0];
                var y = author[1];
                if (maxX == undefined || x > maxX) {
                    maxX = x;
                }
                if (minX == undefined || x < minX) {
                    minX = x;
                }
                if (maxY == undefined || y > maxY) {
                    maxY = y;
                }
                if (minY == undefined || y < minY) {
                    minY = y;
                }
            }
        }
        var lenX = maxX - minX;
        var lenY = maxY - minY;
        if (lenX == 0) {
            lenX = 1;
        }
        if (lenY == 0) {
            lenY = 1;
        }
        for (var key in yearNodePos) {
            if (yearNodePos.hasOwnProperty(key)) {
                var author = yearNodePos[key];
                var x = author[0];
                var y = author[1];
                var posX = baselineService.basicOffset + (x - minX) / lenX * (baselineService.basicHeight - baselineService.basicOffset * 2);
                var posY = baselineService.basicOffset + (y - minY) / lenY * (baselineService.basicHeight - baselineService.basicOffset * 2);
                yearNodePos[key][0] = posX;
                yearNodePos[key][1] = posY;
            }
        }
        return yearNodePos;
    };

    var genFullYearList = function(start, end) {
        if (start < 10000) {
            return d3.range(start, parseInt(end) + 1);
        } else {
            var res = [];
            var stYear = Math.floor(start / 100);
            var edYear = Math.floor(end / 100);
            var stMon = start % 100;
            var edMon = end % 100;
            if (stYear == edYear) {
                for (var i = stMon; i <= edMon; i++) {
                    res.push(stYear * 100 + i);
                }
            } else {
                for (var i = stMon; i <= 12; i++) {
                    res.push(stYear * 100 + i);
                }
                for (var i = stYear + 1; i < edYear; i++) {
                    for (var j = 1; j <= 12; j++) {
                        res.push(i * 100 + j);
                    }
                }
                for (var i = 1; i <= edMon; i++) {
                    res.push(edYear * 100 + i);
                }
            }
            return res;
        }
    };

    var genYearDistance = function(start, end) {
        if (start < 10000) {
            return end - start;
        } else {
            var stYear = Math.floor(start / 100);
            var edYear = Math.floor(end / 100);
            var stMon = start % 100;
            var edMon = end % 100;
            if (stYear == edYear) {
                return edMon - stMon;
            } else {
                return (edYear - stYear - 1) * 12 + 12 - stMon + edMon;
            }
        }
    };

    var genYearList = function(yearDict) {
        var list = [];
        for (var key in yearDict) {
            if (yearDict.hasOwnProperty(key)) {
                list.push(key);
            }
        }
        return list.sort();
    };

    return baselineService;
}]);
