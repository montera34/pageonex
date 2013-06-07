var dataviz = (function () {
// Common data selectors
var getProperty = function (name) { return function (d) { return d[name]; }; };
var getValues = function (d) { return d.values; };
var getKey = function (d) { return d.key; };
// Utility functions
var mapValues = function (a, f) { return {key:a.key, values:a.values.map(f) }; };
var isNonzero = function (d) { return d.percent > 0; };
var formatDate = function (dateString) {
    var d = new Date(dateString + ' 00:00:00');
    return (d.getMonth() + 1) + '/' + d.getDate();
};
// The dataviz object
var dataviz = {
    width: 0,
    height: 0,
    drawCodedThread: function(width, height, padding, thread) {
        // Configuration
        this.width = width;
        this.height = height;
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
            .y(function (d) { return d.percent / d.image_count; })
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
                        return d.y0 + d.percent / d.image_count;
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
        var formatPercent = d3.format(".0%");
        dateX = d3.scale.ordinal()
            .domain(thread.dates)
            .rangeRoundBands([0, chartWidth], 0.1);
        dateLabel = d3.scale.ordinal()
            .domain(thread.dates.map(formatDate))
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
            .scale(dateLabel)
            .orient('bottom');
        chart.append('g')
            .attr('class', 'xaxis')
            .attr('transform', 'translate(' + (padding.left - 0.5) + ',' + (height - padding.bottom + 0.5) + ')')
            .call(xAxis);
        // Scale x axis labels
        d3.selectAll('.xaxis .tick text').attr('font-size', '14');
        //labelWidth = d3.max(d3.selectAll('.xaxis .tick text')[0].map(function f (x) { return x.getBBox().width; }));
        //newSize = 14 * 0.85 * dateX.rangeBand() / labelWidth;
        //d3.selectAll('.xaxis .tick text').attr('font-size', newSize);
        //d3.selectAll('.xaxis text').attr('dy', '10');
        // Draw horizontal lines
        yAxis = d3.svg.axis()
            .scale(yInverse)
            .orient('left')
            .ticks(4)
            .tickFormat(formatPercent);
        chart.selectAll('.yline')
            .data(y.ticks(4))
            .enter()
            .append('line')
            .attr('y1', function (ty) { return Math.floor(y(ty)) + padding.top + 0.5; })
            .attr('y2', function (ty) { return Math.floor(y(ty)) + padding.top + 0.5; })
            .attr('x1', padding.left)
            .attr('x2', width - padding.right)
            .style('stroke', '#eee');
        // Draw y labels
        ylabel = chart.append('g')
            .attr('class', 'yaxis')
            .attr('transform', 'translate(' + (padding.left - 0.5) + ',' + (padding.top + 0.5) + ')')
            .call(yAxis)
            .append('text')
            .text('Mean % of Area')
            .attr('font-size', '12');
        ylabel.attr('dx', (ylabel[0][0].getBBox().height * -0.2)).attr('dy', (ylabel[0][0].getBBox().height * 0.55));
        ylabel.attr('transform', 'rotate(-90)').attr('y', 3).style('text-anchor', 'end');
        d3.selectAll('.yaxis .tick text').attr('dy', d3.select('.yaxis .tick text')[0][0].getBBox().height * 0.25);
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
            .attr('y', function (d) { return height - padding.bottom - Math.floor(y(d.percent / d.image_count + d.y0)); })
            .attr('width', codeX.rangeBand())
            .attr('height', function (d) { return Math.ceil(y(d.percent / d.image_count)); })
            .attr('fill', function (d) { return thread['colors'][d.code]; });
    },
    exportToSvg: function (svgNode, imgNode) {
        html = this.getSvg(svgNode);
        d3.select(imgNode)
            .attr("src", "data:image/svg+xml;base64," + btoa(html));
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
                        total += data.percent / data.image_count;
                }
            }
            content = data.code + ': <strong>' + (100*total).toFixed(1) + '%</strong>';
        });
        return content;
    },
    getSvg: function (node) {
        html = d3.select(node)
            .attr("title", "PageOneX Export")
            .attr("version", 1.1)
            .attr("xmlns", "http://www.w3.org/2000/svg")
            .node().parentNode.innerHTML
        return html;
    }
};
return dataviz;
})();
