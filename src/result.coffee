$ ->
    vis = d3.select('#result-visualisation')
    width = vis.attr('width')
    height = vis.attr('height')
    result = [
        { range: "0", dist:  0.2 },
        { range: "1", dist:  0.3 },
        { range: "4", dist:  0.5 }
    ]

    timeParserMany _.pluck(result, "range"), (err, texts) ->

        MARGINS = 
            top: 10
            bottom: 50
            left: 70
            right: 10

            xaxis:
                right: -10
                down: 10

            yaxis:
                left: 10
                down: 10

        xScale = d3.scale.linear().domain([0,100]).range [MARGINS.left, width - MARGINS.right]
        yScale = d3.scale.linear().domain([0, result.length - 1]).range [height - MARGINS.top - MARGINS.bottom, MARGINS.bottom]

        xAxis = d3.svg.axis().scale(xScale).tickFormat (d) -> "#{d}%"
        yAxis = d3.svg.axis().scale(yScale).orient('left').ticks(result.length).tickFormat (d) -> texts[d]

        vis.append("svg:g")
            .attr("transform", "translate(#{MARGINS.xaxis.right},#{height - (MARGINS.bottom - MARGINS.xaxis.down) })")
            .call xAxis
            .classed 'axis', true

        vis.append("svg:g")
            .attr("transform", "translate(#{MARGINS.left - MARGINS.yaxis.left}, #{MARGINS.yaxis.down + MARGINS.top - MARGINS.bottom})")
            .call yAxis
            .classed 'axis', true

        vis.append('svg:rect')
            .attr "fill", "url(#bars-vertical)"
            .attr "filter", "url(#dropshadow)"
            .attr "width", width - MARGINS.left - MARGINS.right
            .attr "height", height - MARGINS.bottom - MARGINS.top
            .attr 'x', MARGINS.left
            .attr 'y', MARGINS.top


        chart = vis.append('svg:g')
            .selectAll('rect')
            .data(result)
            .enter()
            .append('svg:rect')
            .attr 'height', (height - MARGINS.bottom - MARGINS.top) / result.length
            .attr 'width', (d) -> xScale(d.dist)
            .attr 'x', MARGINS.left
            .attr 'y', (d,i) -> MARGINS.top + i*(height - MARGINS.bottom - MARGINS.top)/result.length
            .attr 'fill', (d) -> LINECOLORS[d.range]
            .attr 'width', (d) -> (width - MARGINS.left - MARGINS.right) * d.dist
