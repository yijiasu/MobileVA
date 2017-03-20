'use strict';

vishope.factory('dataService', ['$http', function($http) {
    var dataService = {
        'NodeObjList': undefined,
        'highlightNodeDict': {},
        'maxAlter': 1,
        'maxStrength': 1,
        'maxSecondAlter': 0,
        'maxTieStr': 1,
        'maxPublication': 1,
        'scrollPos': 0,
        'startYear': undefined,
        'endYear': undefined,
        'authorPubDict': {}
    };

    var serverURL = '';
    //this.NodeObjList = undefined;
    //this.highlightNodeDict = {};

    dataService.getDBList = function() {
        var getDBListURL = serverURL + '/db_list';
        return $http.get(getDBListURL);
    };

    dataService.updateDataset = function(selectedDataset) {
        var _this = this;
        this.NodeObjList = undefined;
        this.highlightNodeDict = {};
        this.maxAlter = 1;
        this.maxStrength = 1;
        this.maxSecondAlter = 0;
        this.maxTieStr = 1;
        this.maxPublication = 1;
        this.scrollPos = 0;
        this.startYear = undefined;
        this.endYear = undefined;
        this.authorPubDict = {};
        //var updateDatasetURL = serverURL + '/get_dataset';
        var getNodeObjListURL = serverURL + '/node_obj_list' + '?name=' + selectedDataset;
        return $http.get(getNodeObjListURL)
            .success(function(data) {
                var maxTuple = calMax(data);
                _this.maxStrDict = genMaxStrDict(data);
                _this.maxAlter = maxTuple[0];
                _this.maxSecondAlter = maxTuple[1];
                _this.maxTieStr = maxTuple[2];
                _this.selectedDataset = selectedDataset;
                _this.NodeObjList = data;
                _this.highlightNodeDict = {};
            });
        //return $http.get(getAuthorObjURL, {'dataset-id': selectedDataset.id})
            //.success(function(data) {
                //_this.dataset = data;
                //_this.datasetID = selectedDataset.id;
            //});
    };

    var genMaxStrDict = function(data) {
        var res = {};
        for (var i = 0; i < data.length; i++) {
            var author = data[i];
            var curRes = genStrStatDict(author['yearDict']);
            var startYear = author['startYear'];
            var endYear = author['endYear'];
            if (dataService.startYear == undefined || parseInt(startYear) < dataService.startYear) {
                dataService.startYear = parseInt(startYear);
            }
            if (dataService.endYear == undefined || parseInt(endYear) > dataService.endYear) {
                dataService.endYear = parseInt(endYear);
            }
            for (var key in curRes) {
                if (curRes.hasOwnProperty(key)) {
                    if ((!res.hasOwnProperty(key)) || (res[key] < curRes[key])) {
                        res[key] = curRes[key];
                    }
                }
            }
        }
        return res;
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


    var genStrStatDict = function(yearDict) {
        var yearList = genYearList(yearDict);
        var res = {};
        for (var i = 0; i < yearList.length; i++) {
            var curDict = yearDict[yearList[i]]['tieStrength'];
            var curRes = {};
            for (var key in curDict) {
                if (curDict.hasOwnProperty(key)) {
                    var value = curDict[key];
                    if (!curRes.hasOwnProperty(value)) {
                        curRes[value] = 0;
                    }
                    curRes[value] += 1;
                }
            }
            for (var key in curRes) {
                if (curRes.hasOwnProperty(key)) {
                    if ((!res.hasOwnProperty(key)) || (res[key] < curRes[key])) {
                        res[key] = curRes[key];
                    }
                }
            }
        }
        return res;
    };

    var calMax = function(data) {
        for (var i = 0; i < data.length; i++) {
            var author = data[i];
            var publicationNum = author['publication'];
            dataService.authorPubDict[author['id']] = {};
            if (publicationNum > dataService.maxPublication) {
                dataService.maxPublication = publicationNum;
            }
            //if (author['yearDict']['2006'] && author['yearDict']['2007'] && author['yearDict']['2008']) {
                //var len1 = author['yearDict']['2006']['neighborList'].length;
                //var len2 = author['yearDict']['2007']['neighborList'].length;
                //var len3 = author['yearDict']['2008']['neighborList'].length;
                //if (len1 < len2 && len2 < len3) {
                    //console.log(author['id'], len1, len2, len3);
                //}
            //}
            for (var year in author['yearDict']) {
                if (author['yearDict'].hasOwnProperty(year)) {
                    var tieStrDict = author['yearDict'][year]['tieStrength'];
                    dataService.authorPubDict[author['id']][year] = author['yearDict'][year]['prePublication'];
                    var alterNum = author['yearDict'][year]['neighborList'].length;
                    var secondAlterNum = author['yearDict'][year]['secondDegreeNeighborList'].length;
                    if (secondAlterNum > dataService.maxSecondAlter) {
                        dataService.maxSecondAlter = secondAlterNum;
                    }
                    if (alterNum > dataService.maxAlter) {
                        dataService.maxAlter = alterNum;
                    }
                    for (var alter in tieStrDict) {
                        if (tieStrDict.hasOwnProperty(alter)) {
                            if (dataService.maxTieStr < tieStrDict[alter]) {
                                dataService.maxTieStr = tieStrDict[alter];
                            }
                        }
                    }
                }
            }
        }
        return [dataService.maxAlter, dataService.maxSecondAlter, dataService.maxTieStr];
    };

    dataService.getMaxAlter = function() {
        return this.maxAlter;
    };

    dataService.getMaxSecondAlter = function() {
        return this.maxSecondAlter;
    };

    dataService.getMaxTieStr = function() {
        return this.maxTieStr;
    };

    dataService.getNodeObjList = function() {
        return this.NodeObjList;
    };

    dataService.getNodeSchema = function() {
        var getNodeSchemaURL = serverURL + '/node_schema' + '?name=' + this.selectedDataset;
        return $http.get(getNodeSchemaURL);
    };

    dataService.getOverviewData = function(dateRange) {
        var getOverviewDataURL = serverURL + '/overview_data';
        return $http.post(getOverviewDataURL, {dataset: dataService.selectedDataset, startDate: dateRange[0], endDate: dateRange[dateRange.length - 1]});
    };

    dataService.recordTask1 = function(res) {
        var recordTask1 = serverURL + '/task1record';
        return $http.post(recordTask1, res);
    };

    dataService.recordTask2 = function(res) {
        var recordTask2 = serverURL + '/task2record';
        return $http.post(recordTask2, res);
    };

    dataService.getOverviewData2 = function(dateRange) {
        var getOverviewDataURL = serverURL + '/overview_data2';
        return $http.post(getOverviewDataURL, {dataset: dataService.selectedDataset, startDate: dateRange[0], endDate: dateRange[dateRange.length - 1]});
    }

    dataService.getStaticOverviewData = function(date) {
        var getOverviewDataURL = serverURL + 'data/ov_' + date[0] + '.json';
        return $http.get(getOverviewDataURL);
    }

    dataService.setHighlightNode = function(node, highlight) {
        var nodeID = node['id'];
        if (highlight) {
            this.highlightNodeDict[nodeID] = node;
        } else {
            delete this.highlightNodeDict[nodeID];
        }
    };

    dataService.getHighlightNodeDict = function() {
        return this.highlightNodeDict;
    };

    dataService.setScrollPos = function(pos) {
        this.scrollPos = pos;
    };

    dataService.getScrollPos = function() {
        return this.scrollPos;
    };

    dataService.getMaxStrDict = function() {
        return this.maxStrDict;
    };

    dataService.getDateRange = function() {
        return [this.startYear, this.endYear];
    };

    dataService.getMaxPublication = function() {
        return this.maxPublication;
    };

    dataService.getAuthorPubDict = function() {
        return this.authorPubDict;
    };

   return dataService;
}]);
