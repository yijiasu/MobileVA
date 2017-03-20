var data = [
  [],
  [1,2,5,6,9], 
  [2,2,5,6,9], 
  [3,2,5,6,9], 
  [1,2,5,6,9], 
  [2,2,5,6,9], 
  [3,2,5,6,9], 
  [3,2,5,6,9], 
  [3,2,5,6,9], 
  [3,2,5,6,9], 
  [3,2,5,6,9],
  []];



// var svg =  d3.select("svg");



var color = d3.scaleOrdinal().range(["#00abc5", "#8a89a6", "#7b6888", "#6b486b", "#005d56", "#00743c", "#008c00"]);

var li = ul.selectAll("li").data(data).enter().append("li");

var arc = d3.arc()
    .outerRadius(radius - 10)
    .innerRadius(radius - border_width);

var pie = d3.pie()
    .sort(null);

var g;
var year = 2006;

// Add a Empty SVG


li.each(function(d, i){
   var svg = d3.select(this).append('svg');
   svg.attr("width", width + text_padding + text_width).attr("height", height);


  g = svg.append("g").attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
  if(i != data.length - 1 && i != 0)
  {
    g.append("text")
    .attr("x", radius - border_width + text_padding)
    .attr("y", 0)
    .style('fill', 'steelblue')
    .style('font-size', '24px')
    .style('font-weight', 'bold')
    .text(year++);
  }

  g.selectAll(".arc").data(function(d){
    // if(d.length == 0)
    // {
    //   return pie([0]);
    // }
    // else
    // {
      return pie(d);
    // }
  }).enter()
  .append("path")
  .attr("class", "arc")
  .attr("d", arc)
  .style("fill", function(d) { return color(d.index); });

})