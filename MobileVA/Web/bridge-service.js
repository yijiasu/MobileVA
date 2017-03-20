var BridgeService = {
  egoData: null,
  visService: null,
  overviewService: null
};

BridgeService.establishBridge = function(egoData){
  this.egoData = egoData;
  this.overviewService = angular.element(document.body).injector().get('overviewVisService');
  this.visService = angular.element(document.body).injector().get('egoVisService');
  console.log("bridge service is established, array length = " + egoData.length);
}
BridgeService.getVisService = function()
{
  return this.visService;
}
BridgeService.loadOverviewData = function(yearOfData) {
  var getOverviewDataURL =  'data/ov_' + yearOfData + '.json';
  $.get(getOverviewDataURL, function(data){
    console.log(data);
  });
}
BridgeService.getNodeViaEgoName = function(queryName)
{
  var node = _.findWhere(this.egoData, { name: queryName });
  return node;
}
BridgeService.drawEgoExpand = function(element, data){
  if (this.visService)
  {
    this.visService.updateTimeline({
        basicWidth:50,
        endYear:2014,
        startYear:1990,
        width:2450
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