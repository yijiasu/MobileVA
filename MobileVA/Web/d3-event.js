jQuery.fn.d3Click = function () {
  this.each(function (i, e) {
    var evt = new MouseEvent("click");
    e.dispatchEvent(evt);
  });
};
jQuery.fn.d3MouseOver = function () {
  this.each(function (i, e) {
    var evt = new MouseEvent("mouseover");
    e.dispatchEvent(evt);
  });
};
jQuery.fn.d3MouseOut = function () {
  this.each(function (i, e) {
    var evt = new MouseEvent("mouseout");
    e.dispatchEvent(evt);
  });
};
