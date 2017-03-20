'use strict';

vishope.directive('tableDirective', function() {
    return {
        restrict: 'A',
        scope: {
            tableConfig: '=',
            tableData: '=',
            highlightNode: '&'
        },
        templateUrl: 'views/tableView.html',
        link: function(scope, element, attrs) {
            var nameBox = d3.select(element[0])
                .append('div')
                .attr('class', 'name-box-d3');

            scope.genHeaderStyle = function(attr, i) {
                return {
                    width: scope.tableConfig.percentages[i] * 100 + '%',
                    display: 'inline-block',
                    border: '1px solid #dddddd'
                };
            };
            scope.genNameTip = function(name,tipList) {
                console.log(name);
                nameBox.remove();
                nameBox = d3.select(element[0]).append('div').attr('class','name-box-d3');
                var _box = nameBox.selectAll('div')
                    .data([name])
                    .enter()
                    .append('div')
                    .style('position','absolute')
                    .style('left',event.clientX +'px')
                    .style('top',event.clientY - 70 +'px')
//                    .style('left',0 +'px')
//                    .style('top',0 +'px')
                    .style('background','white')
                    .style('border-style','solid')
//                    .style('opacity','0.8')
                    .style('border-width','1px')
                    .style('border-color','black')
                    .style('text-align','left')
                    .style('stroke','black')
                    .style('padding', '2px 5px 2px 8px');
                _box.append('text')
                    .text(function(data){
                        return data;
                    })

            };
            scope.mouseLeave = function(){
                d3.selectAll('.name-box-d3').remove();
            };

        }
    };
});
