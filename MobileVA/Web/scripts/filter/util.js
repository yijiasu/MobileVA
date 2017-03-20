'use strict';

vishope.filter('strSlice4', function() {
    return function(text) {
        return text.slice(0, 4);
    }
});

vishope.filter('strSlice1', function() {
    return function(text) {
        return text.slice(0, 1);
    }
});

vishope.filter('replace', function() {
    return function(text) {
        return text.replace('_', '.');
    }
});

vishope.filter('float4', function() {
    return function(text) {
        return d3.format(',.4f')(+text);
    }
});

vishope.filter('integer', function() {
    return function(text) {
        return d3.format('d')(+text);
    }
});

vishope.filter('numberOfShownAttributeInComboBox', function() {
    return function(attrs) {
        var showAttributes = [];
        for (var i = 0; i < attrs.length; i++) {
            if(attrs[i].show){
                showAttributes.push(attrs[i]);
            }
        }
        return showAttributes.length;
    }
});
var tools = tools || {};
tools.getMaxValue = function(elements,choose){
    var max =choose( elements[0]);
    for(var i=1;i<elements.length;i++){
        if(max < choose(elements[i])){
            max = choose(elements[i]);
        }
    }
    return max;
};
tools.getMinValue = function(elements,choose){
    var min =choose( elements[0]);
    for(var i=1;i<elements.length;i++){
        if(min > choose(elements[i])){
            min = choose(elements[i]);
        }
    }
    return min;
};
