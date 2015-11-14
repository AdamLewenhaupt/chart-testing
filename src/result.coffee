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

generateAxises = (vis, result, texts, width, height) ->
        xScale = d3.scale.linear().domain([0,100]).range [MARGINS.left, width - MARGINS.right]
        yScale = d3.scale.linear().domain([0, result.length]).range [height - MARGINS.top, MARGINS.bottom]

        xAxis = d3.svg.axis().scale(xScale).tickFormat (d) -> "#{d}%"
        yAxis = d3.svg.axis().scale(yScale).orient('left').ticks(result.length).tickFormat (d) -> texts[d-1]

        vis.append("svg:g")
            .attr("transform", "translate(#{MARGINS.xaxis.right},#{height - (MARGINS.bottom - MARGINS.xaxis.down) })")
            .call xAxis
            .classed 'axis', true

        vis.append("svg:g")
            .attr("transform", "translate(#{MARGINS.left - MARGINS.yaxis.left}, #{MARGINS.yaxis.down + MARGINS.top})")
            .call yAxis
            .classed 'axis', true

        return xScale

generateBackground = (vis, width, height) ->
    vis.append('svg:rect')
        .attr "fill", "url(#bars-vertical)"
        .attr "filter", "url(#dropshadow)"
        .attr "width", width - MARGINS.left - MARGINS.right
        .attr "height", height - MARGINS.bottom - MARGINS.top
        .attr 'x', MARGINS.left
        .attr 'y', MARGINS.top

generateChart = (vis, result, width, height, xScale) ->
    vis.append('svg:g')
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



generateResult = (result) ->
    vis = d3.select('#result-visualisation')
    vis.selectAll('g').remove()
    width = vis.attr('width')
    height = vis.attr('height')

    timeParserMany _.pluck(result, "range"), (err, texts) ->

        xScale = generateAxises vis, result, texts, width, height
        generateBackground vis, width, height
        generateChart vis, result, width, height, xScale


$ ->

    ranges = Math.floor (Math.random() * 4) + 1
    sample = _.sample([0..4], ranges)

    itr = (memo, num) ->
        d = Math.min((Math.random() + 0.11) * (1 - memo.acc), 1)
        if d > 0.1
            memo.l.push { range: "#{num}", dist: d }
            memo.acc = memo.acc + d
        return memo

    spawn =  _.reduce sample, itr, { l: [], acc: 0 }
    spawn.l[0].dist += 1 - spawn.acc
    
    result = spawn.l

    generateResult result
