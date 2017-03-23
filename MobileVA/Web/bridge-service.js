var BridgeService = {
  egoData: null,
  visService: null,
  overviewService: null
};

BridgeService.establishBridge = function(egoData){
  this.egoData = egoData;
  this.overviewService = angular.element(document.body).injector().get('overviewVisService');
  this.visService = angular.element(document.body).injector().get('egoVisService');
  this.pipService = angular.element(document.body).injector().get('pipService');
  console.log("bridge service is established, array length = " + egoData.length);
}
BridgeService.getVisService = function()
{
  return this.visService;
}
BridgeService.loadOverviewData = function(yearOfData) {
  // var getOverviewDataURL =  'data/ov_' + yearOfData + '.json';
  var getOverviewDataURL = 'ovApi/' + yearOfData + '.json';
  $.get(getOverviewDataURL, function(data){
    console.log(data);
  });
}
BridgeService.getNodeViaEgoName = function(queryName)
{
  var node = _.findWhere(this.egoData, { name: queryName });
  return node;
}
BridgeService.drawEgoExpand = function(element, data, startYear, endYear){
  if (this.visService)
  {
    this.visService.updateTimeline({
        basicWidth:50,
        endYear:endYear,
        startYear:startYear,
        width:(endYear - startYear) * 100 + 50
    });
    this.visService.drawEgoExpand(element, data, true);
  }
}
BridgeService.drawMDS = function (date) {
  this.overviewService.updateOverview(date, "Scatter Plot");
}

BridgeService.genDistributionPreviousYear = function(yearDict) {
  return this.visService.genDistributionPreviousYear(yearDict);
}