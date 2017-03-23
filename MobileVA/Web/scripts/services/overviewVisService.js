'use strict';

vishope.factory('overviewVisService', ['$http', 'dataService', 'pipService',
    function ($http, dataService, pipService) {
        var overviewVisService = {
            basicHeight: 200,
            nodeRadius: 2.5
        };

        overviewVisService.updateOverview = function (dateRange, viewOption) {
            var canvas = d3.select('#densityMapCanvas');
            var height = parseInt(canvas.style('width').slice(0, -2));
            overviewVisService.basicHeight = height - 30;
            canvas.attr('height', (dateRange.length) * this.basicHeight);
            redraw(dateRange, viewOption);
        };

        var redraw = function (dateRange, viewOption) {
            // d3.selectAll('#densityMapCanvas').selectAll('*').remove();
            //drawTimeline(dateRange);
            if (viewOption == "Scatter Plot") {
                drawScatterPlot(dateRange);

            }
            else if (viewOption == "Contour Map") {
                drawDensityMap(dateRange);
            }
        };

        var drawScatterPlot = function (dateRange) {
            var pointWrapper = d3.select('#densityMapCanvas').append('g')
                .attr('class', 'pointWrapper');
            dataService.getStaticOverviewData(dateRange).then(function (promise) {
                var yearNodePos = promise.data;
                var yearDict = {};
                for (var i = 0; i < yearNodePos.length; i++) {
                    yearDict[parseInt(yearNodePos[i]['key'])] = 1;
                }
                yearNodePos = yearNodePos.sort(function (a, b) {
                    return a['key'] - b['key'];
                })
                var newDateRange = [];
                for (var i = 0; i < dateRange.length; i++) {
                    if (yearDict[dateRange[i]]) {
                        newDateRange.push(dateRange[i]);
                    }
                }
                var canvas = d3.select('#densityMapCanvas');
                canvas.attr('height', (newDateRange.length) * overviewVisService.basicHeight);
                scalePos(yearNodePos);
                drawTimeline(newDateRange);
                drawPoint(canvas, pointWrapper, yearNodePos);
                d3.select('#densityMapCanvas').append('g')
                .attr('class', 'lineWrapper');
            });
        };

        var drawPoint = function (svg, wrapper, yearNodePos) {
            var brushDict = {};
            var userYearDict = getUserYearDict(yearNodePos);
            for (var i = 0; i < yearNodePos.length; i++) {

                var tempList = [];
                for (var key in yearNodePos[i]['value']) {
                    if (yearNodePos[i]['value'].hasOwnProperty(key)) {
                        yearNodePos[i]['value'][key]["index"] = i;
                        tempList.push(yearNodePos[i]['value'][key]);
                    }
                }
                var tip = d3.tip()
                    .attr('class', 'd3-tip')
                    .offset([10, 0])
                    .direction('s')
                    .html(function (d) {
                        var str = '<div id="myD3Tip"><ul>';
                        str += '<li> id = ' + d["id"].replace("_", ".") + '</li>';
                        str += '<li> number of 1st-degree neighbor = ' + d["info"]["neighborList"].length + '</li>';
                        str += '<li> density = ' + Math.round(d["info"]["density"] * 100) / 100 + '</li>';
                        str += '<li> edges number = ' + d["info"]["edgeList"].length + '</li>';
                        str += '<li> number of 2nd-degree neighbor = ' + d["info"]["secondDegreeNeighborList"].length + '</li>';
                        str += '</ul></div>';
                        return str;
                    });

                var brushCell;
                var brushStart = function (p) {

                    if (brushCell == undefined) {
                        brushCell = this;
                    }
                    else if (brushCell !== this) {
                        unHighLightAllNodes("circleSelected");
                        removeAllLines("circleSelected");
                        var brushCellClass = d3.select(brushCell).attr('class');
                        var curYearClassName = undefined;
                        if (brushCellClass.length == 45) {
                            curYearClassName = brushCellClass.length - 6;
                        } else {
                            curYearClassName = brushCellClass.length - 4;
                        }
                        var currentYear = brushCellClass.substr(curYearClassName);
                        d3.select(brushCell).call(brushDict[currentYear].clear());
                        brushCell = this;
                    }

                }

                // Highlight the selected circles.
                var brushMove = function () {
                    var brushCellClass = d3.select(brushCell).attr('class');
                    var curYearClassName = undefined;
                    if (brushCellClass.length == 45) {
                        curYearClassName = brushCellClass.length - 6;
                    } else {
                        curYearClassName = brushCellClass.length - 4;
                    }
                    var currentYear = brushCellClass.substr(curYearClassName);
                    var e = brushDict[currentYear].extent();
                    var current = d3.select(this).selectAll("circle");
                    current.classed("circleSelected", function (d) {
                        var posX = d['posX'] + 30 - overviewVisService.nodeRadius;
                        var posY = d["index"] * overviewVisService.basicHeight + d['posY'];
                        var left = Math.min(e[0][0], e[1][0]);
                        var right = Math.max(e[0][0], e[1][0]);
                        var top = Math.min(e[0][1], e[1][1])
                        var bottom = Math.max(e[0][1], e[1][1]);
                        var isSelected = (left <= posX && posX <= right && top <= posY && posY <= bottom);
                        if (isSelected) {
                            highLightUserAllYears(d, "circleSelected");
                            drawLineForHighLightNodes(d, "circleSelected");
                        } else {
                            unHighLightUserAllYears(d, "circleSelected");
                            removeLineForUnHighLightNodes(d,"circleSelected");
                        }
                        return isSelected;
                    });
                }

                // var fisheye = d3.fisheye.circular()
                //             .radius(100)
                //             .distortion(6);

                var brush = d3.svg.brush()

                    .x(d3.scale.identity().domain([ 30 - overviewVisService.nodeRadius,  30 - overviewVisService.nodeRadius+overviewVisService.basicHeight]))
                    .y(d3.scale.identity().domain([i * overviewVisService.basicHeight, (i + 1) * overviewVisService.basicHeight]))
                    .on("brushstart", brushStart)
                    .on("brush", brushMove)
                brushDict[yearNodePos[i]['key']] = brush;
                var yearPointWrapper = wrapper.append('g')
                    .attr('class', 'brush yearPointWrapper yearPointWrapper' + yearNodePos[i]['key']);
                    // .call(brush);
                var nodeDict = dataService.getHighlightNodeDict();
                var points = yearPointWrapper.selectAll('.overviewPoint')
                    .data(tempList)
                    .enter()
                    .append('circle')
                    .attr('data-key', function(d){
                      return d['id'];
                    })
                    .attr('class', function (d) {
                        var name = d['id'].replace(/\s+/g, '').replace('@', '').replace('\'', '');
                         var s = 'overviewPoint ' + " pointName" + name;
                            if (nodeDict.hasOwnProperty(d['id'])) {
                                s += ' tableSelected';
                            }
                            return s;
                    })
                    .attr('cx', function (d) {
                        return d['posX'] + 30 - overviewVisService.nodeRadius;
                    })
                    .attr('cy', function (d) {
                        return i * overviewVisService.basicHeight + d['posY'] - overviewVisService.nodeRadius;
                    })
                    .attr('r', overviewVisService.nodeRadius)
                    .attr('fill', 'grey')
                    .attr('fill-opacity', 0.3)
                    //.attr('stroke', 'white')
                    //.attr('stroke-width', 1)
                    .on('mouseover', function (d) {
                        pipService.emitOverviewClicked(d.id);
                        // if (d.cnt != 0) {
                        //     tip.show(d);
                        //     highLightUserAllYears(d, "hovered");
                        //     drawLineForHighLightNodes(d, "hovered");
                        // }
                    })
                    .on('mouseout', function (d) {
                        if (d.cnt != 0) {
                            tip.hide(d)
                            unHighLightUserAllYears(d, "hovered");
                            removeLineForUnHighLightNodes(d,"hovered");
                        }
                    })
                    .on('mousedown', function (d) {
                        // pipService.emitOverviewClicked(d.id);
                    });
                yearPointWrapper.call(tip);
                // console.log('hello');
                // console.log(svg);
                // svg.on("mousemove", function(){
                //     // console.log(points);
                //     // console.log("mousemove");
                //     fisheye.focus(d3.mouse(this));
                //     points.each(function(d) {d.fisheye = fisheye(d); })
                //         .attr("cx", function(d) { return d.fisheye.x; })
                //         .attr("cy", function(d) { return d.fisheye.y; })
                //         .attr("r", function(d) { return d.fisheye.z * 4.5; });

                // });
                // svg.on("touchmove", function(){
                //     // console.log(points);
                //     fisheye.focus(d3.to(this));
                //     points.each(function(d) {d.fisheye = fisheye(d); })
                //         .attr("cx", function(d) { return d.fisheye.x; })
                //         .attr("cy", function(d) { return d.fisheye.y; })
                //         .attr("r", function(d) { return d.fisheye.z * 4.5; });

                // });

                // svg.on("custom", function(e){
                //     console.log(e);
                // });
                // // svg.on("custom", function(e))

            }
        };

        var highLightUserAllYears = function (node, className) {
            var nameClass = ".pointName" + node['id'].replace(/\s+/g, '').replace('@', '').replace('\'', '');
            d3.selectAll(nameClass).classed(className, true);
        }
        var unHighLightUserAllYears = function (node, className) {
            var nameClass = ".pointName" + node['id'].replace(/\s+/g, '').replace('@', '').replace('\'', '');
            d3.selectAll(nameClass).classed(className, false);
        }
        var unHighLightAllNodes = function (className) {
            d3.selectAll(".yearPointWrapper").selectAll("*").classed(className, false);
        }
        overviewVisService.highLightNodeFromTable = function (node) {
            var nodeId = node['id'].replace(/\s+/g, '').replace('@', '').replace('\'', '');
            var pointWrapper = d3.selectAll('.pointName' + nodeId).classed('tableSelected', node['highlight']);
            if(node['highlight']){
                drawLineForHighLightNodes(node, "tableSelected");
            }
            else{
                removeLineForUnHighLightNodes (node,"tableSelected");
            }
        }
        var drawLineForHighLightNodes = function (node, className) {
            var nodeName = node['id'].replace(/\s+/g, '').replace('@', '').replace('\'', '');
            var nameClass = ".pointName" + nodeName;
            var prevNode = undefined;
            var lineWrapper = d3.select(".lineWrapper");
            d3.selectAll(nameClass).each(function (d, i) {
                if (i != 0) {
                    var x1 = d3.select(this).attr('cx');
                    var y1 = d3.select(this).attr('cy');
                    var x2 = d3.select(prevNode).attr('cx');
                    var y2 = d3.select(prevNode).attr('cy');
                    lineWrapper
                        .append('line')
                        .attr('class', 'lineOverView '+className+' lineOverView'+nodeName)
                        .attr('x1',x1)
                        .attr('y1',y1)
                        .attr('x2',x2)
                        .attr('y2',y2)
                }
                prevNode = this;
            })
        }
        var removeLineForUnHighLightNodes = function (node, className) {
            var lineWrapper = d3.select(".lineWrapper");
            var nodeName = node['id'].replace(/\s+/g, '').replace('@', '').replace('\'', '');
            d3.selectAll('.'+className+'.lineOverView'+nodeName).remove();
        }
         var removeAllLines = function (className) {
            d3.selectAll('.lineOverView.'+className).remove();
        }
        var getUserYearDict = function (yearNodePos) {
            var userYearDict = {};
            for (var i = 0; i < yearNodePos.length; i++) {
                var year = yearNodePos[i]["key"];
                var userDict = yearNodePos[i]["value"];
                for (var userID in userDict) {
                    if (userDict.hasOwnProperty(userID)) {
                        if (!userYearDict.hasOwnProperty(userID)) {
                            userYearDict[userID] = [];
                        }
                        userYearDict[userID].push(year);
                    }
                }
            }
            return userYearDict;
        }
        var scalePos = function (yearNodePos) {
            var maxX = undefined;
            var minX = undefined;
            var maxY = undefined;
            var minY = undefined;
            for (var i = 0; i < yearNodePos.length; i++) {
                for (var key in yearNodePos[i]['value']) {
                    if (yearNodePos[i]['value'].hasOwnProperty(key)) {
                        var author = yearNodePos[i]['value'][key];
                        var x = author['x'];
                        var y = author['y'];
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
            }
            var lenX = maxX - minX;
            var lenY = maxY - minY;
            if (lenX == 0) {
                lenX = 1;
            }
            if (lenY == 0) {
                lenY = 1;
            }
            for (var i = 0; i < yearNodePos.length; i++) {
                for (var key in yearNodePos[i]['value']) {
                    if (yearNodePos[i]['value'].hasOwnProperty(key)) {
                        var author = yearNodePos[i]['value'][key];
                        var x = author['x'];
                        var y = author['y'];
                        var posX = (x - minX) / lenX * (overviewVisService.basicHeight);
                        var posY = (y - minY) / lenY * overviewVisService.basicHeight;
                        author['posX'] = posX;
                        author['posY'] = posY;
                    }
                }
            }
        };
        var drawDensityMap = function (dateRange) {
            var pointWrapper = d3.select('#densityMapCanvas')
                .append('g')
                .attr('class', 'pointWrapper');
            dataService.getOverviewData2(dateRange).then(function (promise) {
                var yearNodePos = promise.data;
                var yearDict = {};
                for (var i = 0; i < yearNodePos.length; i++) {
                    yearDict[parseInt(yearNodePos[i]['key'])] = 1;
                }
                var newDateRange = [];
                for (var i = 0; i < dateRange.length; i++) {
                    if (yearDict[dateRange[i]]) {
                        newDateRange.push(dateRange[i]);
                    }
                }
                scalePos(yearNodePos);
                drawTimeline(newDateRange);

                for (var i = 0; i < yearNodePos.length; i++) {
                    var yearNode = yearNodePos[i];
                    var yearNodeList = reformatYearNode(yearNode);
                    var pix = 2;
                    var scale = 8;
                    contourMap(yearNodeList, pointWrapper, pix, scale, '#2E64FE', i);
                }
            });
        };
        var reformatYearNode = function (yearNode) {
            var yearNodeList = [];
            for (var key in yearNode['value']) {
                if (yearNode['value'].hasOwnProperty(key)) {
                    var author = yearNode['value'][key];
                    var x = author['posX'];
                    var y = author['posY'];
                    var pos = {'x': x, 'y': y};
                    yearNodeList.push(pos);
                }
            }
            return yearNodeList;
        };
        var drawTimeline = function (dateRange) {
            var timelineWrapper = d3.select('#densityMapCanvas').append('g')
                .attr('class', 'timelineWrapper');
            var timelineLen = dateRange.length * overviewVisService.basicHeight;
            timelineWrapper.selectAll('.timelineBar')
                .data(dateRange)
                .enter()
                .append('line')
                .attr('class', '.timeline')
                .attr('x1', function (d, i) {
                    return 35;
                })
                .attr('y1', function (d, i) {
                    return overviewVisService.basicHeight / 2 + i * overviewVisService.basicHeight - overviewVisService.nodeRadius;
                })
                .attr('x2', function (d, i) {
                    return 40;
                })
                .attr('y2', function (d, i) {
                    return overviewVisService.basicHeight / 2 + i * overviewVisService.basicHeight - overviewVisService.nodeRadius;
                })
                .attr('stroke', 'black')
                .attr('stroke-width', 2)
                .attr('stroke-opacity', 0);
            timelineWrapper.selectAll('.timelineLabel')
                .data(dateRange)
                .enter()
                .append('text')
                .attr('class', 'timelineLabel')
                .attr('x', function (d, i) {
                    return 0;
                })
                .attr('y', function (d, i) {
                    return overviewVisService.basicHeight / 2 + i * overviewVisService.basicHeight;
                })
                .attr('dx', 0)
                .attr('dy', 2)
                .text(function (d) {
                    return d;
                });
            //timelineWrapper.attr('transform', 'rotate(90, 20, 0)');
            d3.select('#densityMapCanvas').append('g')
                .attr('class', 'timelineBreakLines')
                .selectAll('.timelineBar')
                .data(dateRange)
                .enter()
                .append('line')
                .attr('class', '.timeline')
                .attr('y1', function (d, i) {
                    return overviewVisService.basicHeight + i * overviewVisService.basicHeight ;
                })
                .attr('x1', 35)
                .attr('y2', function (d, i) {
                    return overviewVisService.basicHeight + i * overviewVisService.basicHeight ;
                })
                .attr('x2', overviewVisService.basicHeight)
                .attr('stroke', '#eeeeee')
                .attr('stroke-width', 1)
                .attr('stroke-opacity', 1);
        };

        overviewVisService.reset = function () {
            d3.selectAll('#densityMapCanvas').selectAll('*').remove();
            var canvas = d3.select('#densityMapCanvas');
            canvas.attr('height', 0);
        };

        var genYearDistance = function (start, end) {
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

        var contourMap = function (data, svg, pix, scale, color, index) {
            var maxValue = 300;
            var start = 1;
            var end = 300;
            var step = 50;

            var grid = [];
            var left = d3.min(data, function (d) {
                return d.x;
            }) - scale;
            var right = d3.max(data, function (d) {
                return d.x;
            }) + scale;
            var top = d3.min(data, function (d) {
                return d.y
            }) - scale;
            var bottom = d3.max(data, function (d) {
                return d.y
            }) + scale;
            for (var i = left; i < right; i += pix) {
                for (var j = top; j < bottom; j += pix) {
                    grid.push({x: i, y: j});
                }
            }
            var kde = kernelDensityEstimator(epanechnikovKernel(scale), grid);
            var raw_data = kde(data);
            //console.log('raw_data');
            //console.log(raw_data)
            //console.log('max');
            /*console.log(d3.max(raw_data, function (d) {
             return d.z;
             }));
             */
            var scaleValue = d3.scale.linear()
                .domain([0, d3.max(raw_data, function (d) {
                    return d.z;
                })])
                .range([0, maxValue]);

            var count = 0;
            var grid_data = [];
            for (i = left; i < right; i += pix) {
                var tmp = [];
                for (j = top; j < bottom; j += pix) {
                    tmp.push(scaleValue(raw_data[count++].z));
                }
                grid_data.push(tmp);
            }
            var cliff = -100;
            grid_data.push(d3.range(grid_data[0].length).map(function () {
                return cliff;
            }));
            grid_data.unshift(d3.range(grid_data[0].length).map(function () {
                return cliff;
            }));
            grid_data.forEach(function (d) {
                d.push(cliff);
                d.unshift(cliff);
            });
            /*
             * @param {number[][]} d - matrix of data to contour
             * @param {number} ilb,iub,jlb,jub - index bounds of data matrix
             *
             *             The following two, one dimensional arrays (x and y) contain
             *             the horizontal and vertical coordinates of each sample points.
             * @param {number[]} x  - data matrix column coordinates
             * @param {number[]} y  - data matrix row coordinates
             * @param {number} nc   - number of contour levels
             * @param {number[]} z  - contour levels in increasing order.
             */
            //Conrec.prototype.contour = function (d, ilb, iub, jlb, jub, x, y, nc, z) {
            var c = new Conrec,
                xs = d3.range(0, grid_data.length),
                ys = d3.range(0, grid_data[0].length),
                zs = [10, 60, 160],
                x = d3.scale.linear().range([left, right]).domain([0, grid_data.length]),
                y = d3.scale.linear().range([top, bottom]).domain([0, grid_data[0].length]),
                colours = d3.scale.linear().domain([-200, 160]).range(["#fff", color]);
            c.contour(grid_data, 0, xs.length - 1, 0, ys.length - 1, xs, ys, zs.length, zs);
            svg.selectAll(".yearPointContour" + index)
                .data(c.contourList())
                .enter()
                .append("path")
                .attr("class", "yearPointContour" + index)
                .style("fill", function (d) {
                    return colours(d.level);
                })
                .style("stroke", function (d) {
                    return colours(d.level);
                })
                .style("fill-opacity", 0.3)
                .attr("d", d3.svg.line()
                    .x(function (d) {
                        return x(d.x) + 30 - overviewVisService.nodeRadius
                    })
                    .y(function (d) {
                        return y(d.y) + index * overviewVisService.basicHeight - overviewVisService.nodeRadius;
                    }));

            function kernelDensityEstimator(kernel, grid) {
                return function (sample) {
                    return grid.map(function (grid) {
                        return {x: grid.x, y: grid.y, z: d3.mean(sample, function (g) {
                            var d = Math.sqrt((grid.x - g.x) * (grid.x - g.x) + (grid.y - g.y) * (grid.y - g.y));
                            var tmp = kernel(d);
                            return 10 * tmp;
                        })};
                    });
                };
            }

            function epanechnikovKernel(scale) {
                return function (u) {
                    return Math.abs(u /= scale) <= 1 ? .75 * (1 - u * u) / scale : 0;
                };
            }

        };
        return overviewVisService;
    }
])
;
