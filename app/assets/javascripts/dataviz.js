var dataviz = (function () {
// Common data selectors
var getProperty = function (name) { return function (d) { return d[name]; }; };
var getValues = function (d) { return d.values; };
var getKey = function (d) { return d.key; };

var mapValues = function (a, f) { return {key:a.key, values:a.values.map(f) }; };
var isNonzero = function (d) { return d.percent > 0; };

var dataviz = {
    drawCodedThread: function(width, height, padding, thread) {
        // Configuration
        var chartHeight = height - padding.top - padding.bottom;
        var chartWidth = width - padding.left - padding.right;
        // Convert flat data to a nested tree
        nest = d3.nest()
            .key(function (d) { return d.date; })
            .key(function (d) { return d.code; })
            .key(function (d) { return d.media; })
        data = nest.entries(thread.data)
        // Create a layout to stack newspapers on the same d
        dateIndex = d3.scale.ordinal()
            .domain(thread.dates)
            .range([0, thread.dates.length - 1]);
        stack = d3.layout.stack()
            .values(function (d) { return d.values; })
            .x(function (d) { return dateIndex(d.date); })
            .y(function (d) { return d.percent; })
            .out(function (d, y0, y) { d.y0 = y0; });
        // Apply stack layout to data with the same code
        data = data.map(function (date) {
            return mapValues(date, function (code) {
                return {key:code.key, values:stack(code.values)};
            });
        });
        // Calculate maximum stacked value
        domainMax = d3.max(data, function (date) {
            return d3.max(date.values, function (code) {
                return d3.max(code.values, function (media) {
                    return d3.max(media.values, function (d) {
                        return d.y0 + d.percent;
                    });
                });
            });
        });
        // Create scales
        y = d3.scale.linear()
            .domain([0, domainMax])
            .range([0, chartHeight]);
        yInverse = d3.scale.linear()
            .domain([0, domainMax])
            .range([chartHeight, 0]);
        dateX = d3.scale.ordinal()
            .domain(thread.dates)
            .rangeRoundBands([0, chartWidth], 0.1);
        codeX = d3.scale.ordinal()
            .domain(thread.codes)
            .rangeRoundBands([0, dateX.rangeBand()], 0.025);
        // Draw the chart
        chart = d3.select('#chart_div')
            .append('svg')
            .attr('width', width)
            .attr('height', height)
            .append('g')
        // Draw axes
        xAxis = d3.svg.axis()
            .scale(dateX)
            .orient('bottom');
        chart.append('g')
            .attr('transform', 'translate(' + (padding.left - 0.5) + ',' + (height - padding.bottom + 0.5) + ')')
            .call(xAxis);
        yAxis = d3.svg.axis()
            .scale(yInverse)
            .orient('left')
            .ticks(5);
        chart.selectAll('.yline')
            .data(y.ticks(5))
            .enter()
            .append('line')
            .attr('y1', function (ty) { return Math.floor(y(ty)) + padding.top + 0.5; })
            .attr('y2', function (ty) { return Math.floor(y(ty)) + padding.top + 0.5; })
            .attr('x1', padding.left)
            .attr('x2', width - padding.right)
            .style('stroke', '#ccc');
        chart.append('g')
            .attr('transform', 'translate(' + (padding.left - 0.5) + ',' + (padding.top + 0.5) + ')')
            .call(yAxis)
            .append('text')
            .attr('transform', 'rotate(-90)')
            .attr('y', 3)
            .attr('dx', '-0.2em')
            .attr('dy', '.71em')
            .style('text-anchor', 'end')
            .text('Area');
        d3.selectAll('svg .domain').attr('stroke', 'black').attr('fill', 'none');
        d3.selectAll('svg .tick line').attr('stroke', 'black').attr('fill', 'none');
        // Draw bars
        date = chart.selectAll('.date').data(data, getKey);
        date.enter()
            .append('g')
            .attr('class', 'date');
        code = date.selectAll('.code').data(getValues, getKey);
        code.enter()
            .append('g')
            .attr('class', 'code')
            .attr('transform', function (d) { return 'translate(' + codeX(d.key) + ',0)'; });
        media = code.selectAll('.media').data(getValues, getKey);
        media.enter().append('g')
            .attr('class', 'media');
        percent = media.selectAll('.percent').data(function (d) { return d.values.filter(isNonzero); }, getProperty('id'));
        percent.enter()
            .append('rect')
            .attr('x', function (d,i) { return padding.left + dateX(d.date); })
            .attr('y', function (d) { return height - padding.bottom - Math.floor(y(d.percent + d.y0)); })
            .attr('width', codeX.rangeBand())
            .attr('height', function (d) { return Math.ceil(y(d.percent)); })
            .attr('fill', function (d) { return thread['colors'][d.code]; })
            .attr('class', function (d) { return 'debug-' + (Math.ceil(y(d.percent))); });
    },
    getTitle: function (node) {
        var title = '';
        d3.select(node).each(function (d) {
            title = d.values[0].values[0].date;
        });
        return title;
    },
    getContent: function (node) {
        var content = '';
        d3.select(node).each(function (d) {
            total = 0;
            for (var i = 0; i < d.values.length; i++) {
                media = d.values[i];
                for (var j = 0; j < media.values.length; j++) {
                    data = media.values[j];
                        total += data.percent;
                }
            }
            content = data.code + ': <strong>' + total + '</strong>';
        });
        return content;
    }
};
return dataviz;
})();