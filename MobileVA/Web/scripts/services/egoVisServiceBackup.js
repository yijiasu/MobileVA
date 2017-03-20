 var drawGlyphLine2 = function(egoGlyphWrapper, egoData) {
        var timelineConfig = egoVisService.timelineConfig;
        var yearList = genYearList(egoData['yearDict']);
        var flowList = genFlowList(egoData['yearDict']);
        var tip = d3.tip()
            .attr('class', 'd3-tip')
            .offset([10, 0])
            .direction('s')
            .html(function(d) {
                var str = '<div id="myD3Tip"><ul>';
                for (var i = 0; i < d.nameList.length; i++) {
                    var atomStr = '<li>' + d.nameList[i] + '</li>';
                    str += atomStr;
                }
                str += '</ul></div>';
                return str;
            });
        egoGlyphWrapper.call(tip);
        egoGlyphWrapper.selectAll('.egoGlyphLine')
            .data(flowList)
            .enter()
            .append('line')
            .attr('class', 'egoGlyphLine')
            .attr('x1', function(d) {
                var radius1 = calGlyphRadius(egoData['yearDict'][d.startYear]['neighborList'].length);
                var radius2 = calGlyphRadius(egoData['yearDict'][d.startYear]['secondDegreeNeighborList'].length);
                return genYearDistance(egoData.startYear, d.startYear) * 100 +
                timelineConfig.basicWidth / 2 + Math.max(radius1, radius2);
            })
            .attr('y1', timelineConfig.basicWidth / 2)
            .attr('x2', function(d) {
                var radius1 = calGlyphRadius(egoData['yearDict'][d.endYear]['neighborList'].length);
                var radius2 = calGlyphRadius(egoData['yearDict'][d.endYear]['secondDegreeNeighborList'].length);
                return genYearDistance(egoData.startYear, d.endYear) * 100 +
                timelineConfig.basicWidth / 2 - Math.max(radius1, radius2);
            })
            .attr('y2', timelineConfig.basicWidth / 2)
            .attr('stroke', function(d) {
                var value = d.strength / d.cnt;
                value = value / 0.5;
                if (value > 0) {
                    value = Math.min(value, 3);
                    value = Math.floor(value);
                    return egoVisService.lineColor[value];
                } else if (value < 0) {
                    value = -value;
                    value = Math.min(value, 3);
                    value = Math.floor(value);
                    return egoVisService.lineColor[5 + value];
                } else {
                    return egoVisService.lineColor[4];
                }
            })
            .attr('stroke-width', function(d) {
                if (d.cnt == 0) {
                    return 2;
                } else {
                    return 1 + d.cnt;
                }
            })
            .attr('stroke-dasharray', function(d) {
                if (d.cnt == 0) {
                    return '5, 5';
                } else {
                    return 'none';
                }
            })
            .on('mouseover', function(d) {
                if (d.cnt != 0) {
                    tip.show(d);
                }
            })
            .on('mouseout', function(d) {
                if (d.cnt != 0) {
                    tip.hide(d);
                }
            });

    };


    var drawGlyphCircle1 = function(egoGlyphWrapper, egoData) {
        var timelineConfig = egoVisService.timelineConfig;
        var yearList = genYearList(egoData['yearDict']);
        var alterArcWrapper = egoGlyphWrapper.selectAll('.alterArcWrapper')
            .data(yearList)
            .enter()
            .append('g')
            .attr('class', 'alterArcWrapper')
            .attr('transform', function(d) {
                return 'translate(' + (genYearDistance(egoData.startYear, d) * 100 +
                        timelineConfig.basicWidth / 2) + ',' +
                        (timelineConfig.basicWidth / 2) + ')';
            });

        var pie = d3.layout.pie()
            .sort(null)
            .value(function(d) {
                return d;
            });

        var tip = d3.tip()
            .attr('class', 'd3-tip')
            .offset([10, 0])
            .direction('s')
            .html(function(d) {
                var str = '<div id="myD3Tip"><ul>';
                for (var i = 0; i < d.nameList.length; i++) {
                    var atomStr = '<li>' + d.nameList[i] + '</li>';
                    str += atomStr;
                }
                str += '</ul></div>';
                return str;
            });

        //var distributionDict = genDistributionLastYear(egoData['yearDict']);
        var distributionDict = genDistributionPreviousYear(egoData['yearDict']);

        alterArcWrapper.call(tip);
        var alterArc = alterArcWrapper.selectAll('.alterArc')
            .data(function(d) {
                var res = [];
                for (var i = 0; i < distributionDict[d].length; i++) {
                    res.push(distributionDict[d][i]['cnt']);
                }
                var res = pie(res);
                for (var i = 0; i < res.length; i++) {
                    var radius1 = calGlyphRadius(getLen(egoData['yearDict'][d]['tieStrength']));
                    var radius2 = calGlyphRadius(egoData['yearDict'][d]['secondDegreeNeighborList'].length);
                    //res[i]['outerRadius'] = genOuterRadius(getLen(egoData['yearDict'][d]['tieStrength']));
                    var outerRadius = Math.max(radius1, radius2);
                    var innerRadius = Math.min(radius1, radius2);
                    if (outerRadius - innerRadius <= 4) {
                        var dif = outerRadius - innerRadius;
                        outerRadius += (4 - dif);
                    }
                    res[i]['outerRadius'] = outerRadius;
                    res[i]['innerRadius'] = innerRadius;
                    res[i]['nameList'] = distributionDict[d][i]['nameList'];
                }
                return res;
            })
            .enter()
            .append('g')
            .attr('class', '.alterArc');

        alterArc.append('path')
            .attr('d', function(d) {
                var arc = d3.svg.arc()
                    .outerRadius(d.outerRadius)
                    .innerRadius(d.innerRadius);
                    //.innerRadius(egoVisService.innerRadius);
                return arc(d);
            })
            .style('fill', function(d, i) {
                return egoVisService.arcColor[i];
            })
            .on('mouseover', function(d) {
                d3.select(this)
                    .attr('stroke', 'white')
                    .attr('stroke-width', 1);
                tip.show(d);
            })
            .on('mouseout', function(d) {
                d3.select(this)
                    .attr('stroke', 'none')
                    .attr('stroke-width', 0);
                tip.hide(d);
            });

        egoGlyphWrapper.selectAll('.denCircle')
            .data(yearList)
            .enter()
            .append('circle')
            .attr('class', 'denCircle')
            .attr('cx', function(d) {
                return genYearDistance(egoData.startYear, d) * 100 +
                timelineConfig.basicWidth / 2;
            })
            .attr('cy', timelineConfig.basicWidth / 2)
            .attr('r', function(d) {
                var alterNum = egoData['yearDict'][d]['neighborList'].length;
                var secAlterNum = egoData['yearDict'][d]['secondDegreeNeighborList'].length;
                return calGlyphRadius(Math.min(alterNum, secAlterNum));
            })
            .style('fill', function(d) {
                var edgeNum = egoData['yearDict'][d]['edgeList'].length;
                var alterNum = egoData['yearDict'][d]['neighborList'].length;
                var secAlterNum = egoData['yearDict'][d]['secondDegreeNeighborList'].length;
                var value = undefined;
                if (alterNum == 1) {
                    value = 4;
                } else {
                    value = edgeNum * 2 / (alterNum * (alterNum - 1));
                    value = Math.floor(value * 4);
                }
                if (alterNum > secAlterNum) {
                    return egoVisService.densityColorYellow[value];
                } else if (alterNum < secAlterNum){
                    return egoVisService.densityColorPurple[value];
                } else {
                    return '#f7f7f7';
                }
            });

    };

    var drawGlyphCircle2 = function(egoGlyphWrapper, egoData) {
        var timelineConfig = egoVisService.timelineConfig;
        var yearList = genYearList(egoData['yearDict']);
        var alterArcWrapper = egoGlyphWrapper.selectAll('.alterArcWrapper')
            .data(yearList)
            .enter()
            .append('g')
            .attr('class', 'alterArcWrapper')
            .attr('transform', function(d) {
                return 'translate(' + (genYearDistance(egoData.startYear, d) * 100 +
                        timelineConfig.basicWidth / 2) + ',' +
                        (timelineConfig.basicWidth / 2) + ')';
            });

        var pie = d3.layout.pie()
            .sort(null)
            .value(function(d) {
                return d;
            });

        var tip = d3.tip()
            .attr('class', 'd3-tip')
            .offset([10, 0])
            .direction('s')
            .html(function(d) {
                var str = '<div id="myD3Tip"><ul>';
                for (var i = 0; i < d.nameList.length; i++) {
                    var atomStr = '<li>' + d.nameList[i] + '</li>';
                    str += atomStr;
                }
                str += '</ul></div>';
                return str;
            });

        //var distributionDict = genDistributionLastYear(egoData['yearDict']);
        var distributionDict = genDistributionPreviousYear(egoData['yearDict']);

        alterArcWrapper.call(tip);
        var alterArc = alterArcWrapper.selectAll('.alterArc')
            .data(function(d) {
                var res = [];
                for (var i = 0; i < distributionDict[d].length; i++) {
                    res.push(distributionDict[d][i]['cnt']);
                }
                var res = pie(res);
                for (var i = 0; i < res.length; i++) {
                    //var radius1 = calGlyphRadius(getLen(egoData['yearDict'][d]['tieStrength']));
                    //var radius2 = calGlyphRadius(egoData['yearDict'][d]['secondDegreeNeighborList'].length);
                    res[i]['outerRadius'] = calGlyphRadius(egoData['yearDict'][d]['neighborList'].length);
                    //var outerRadius = Math.max(radius1, radius2);
                    //var innerRadius = Math.min(radius1, radius2);
                    //if (outerRadius - innerRadius <= 3) {
                        //var dif = outerRadius - innerRadius;
                        //outerRadius += (4 - dif);
                    //}
                    //res[i]['outerRadius'] = outerRadius;
                    //res[i]['innerRadius'] = innerRadius;
                    res[i]['nameList'] = distributionDict[d][i]['nameList'];
                    res[i]['edgeNum'] = egoData['yearDict'][d]['edgeList'].length;
                    res[i]['alterNum']= egoData['yearDict'][d]['neighborList'].length;
                }
                return res;
            })
            .enter()
            .append('g')
            .attr('class', '.alterArc');

        alterArc.append('path')
            .attr('d', function(d) {
                var arc = d3.svg.arc()
                    .outerRadius(d.outerRadius)
                    .innerRadius(0);
                    //.innerRadius(egoVisService.innerRadius);
                return arc(d);
            })
            .style('fill', function(d, i) {
                return egoVisService.arcColor[i];
            })
            .style('fill-opacity', function(d) {
                var edgeNum = d['edgeNum'];
                var alterNum = d['alterNum'];
                var value = undefined;
                if (alterNum == 1) {
                    value = 1;
                } else {
                    value = edgeNum * 2 / (alterNum * (alterNum - 1));
                    value = 0.4 + value * 0.6
                }
                return value;
            })
            .on('mouseover', function(d) {
                d3.select(this)
                    .attr('stroke', 'white')
                    .attr('stroke-width', 1);
                tip.show(d);
            })
            .on('mouseout', function(d) {
                d3.select(this)
                    .attr('stroke', 'none')
                    .attr('stroke-width', 0);
                tip.hide(d);
            });

        egoGlyphWrapper.selectAll('.denCircle')
            .data(yearList)
            .enter()
            .append('circle')
            .attr('class', 'denCircle')
            .attr('cx', function(d) {
                return genYearDistance(egoData.startYear, d) * 100 +
                timelineConfig.basicWidth / 2;
            })
            .attr('cy', timelineConfig.basicWidth / 2)
            .attr('r', function(d) {
                //var alterNum = egoData['yearDict'][d]['neighborList'].length;
                var secAlterNum = egoData['yearDict'][d]['secondDegreeNeighborList'].length;
                return calGlyphRadius(secAlterNum);
            })
            .style('fill', 'none')
            .attr('stroke', 'black')
            .attr('stroke-width', 1);

    };

