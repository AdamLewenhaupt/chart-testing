colorOffset = 40
colorStep = 60
LINECOLORS = []

for i in [1..5]
    LINECOLORS.push "hsl(#{colorOffset + colorStep * i}, 60%, 60%"


DRAGGING = false
INACTIVE = _.map _.range(5), (x) -> false
GRAPH_MARGINS = 
    top: 0
    right: 20
    bottom: 10
    left: 50
    xaxis: 
        right: 5
        down: 10
    yaxis: 
        left: 5
        down: 10


createDrag = (yScale, information, lineGen) ->
    main  = this
    d3.behavior.drag()
        .on "dragstart", (d) -> 
            d3.event.sourceEvent.stopPropagation()
            d3.select(this).classed("dragging", true)

        .on "drag", (d) ->
            DRAGGING = true
            inv = yScale.invert d3.event.y
            dot = d3.select(this)
            inBounds = 0 <= inv <= 5
            if inBounds
                dot.attr 'cy', d3.event.y    
                range = _.findWhere(information, { range: +dot.attr('range-index') })

                range.prediction[dot.attr("index")] = 
                    year: dot.attr("index")
                    percentage: inv

                main.lines[dot.attr('range-index')].line.attr 'd', lineGen(range.prediction)

        .on "dragend", (d) ->
            DRAGGING = false
            d3.select(this).classed("dragging", false)
            onMouseLeaveLineOrDot.call this, d, main.lines


generateGraphAxises = (vis, xScale, yScale, height) ->
    precisionFormat = d3.format(".1f")

    xAxis = d3.svg.axis().scale(xScale).ticks(6).tickFormat (d) -> 
        if d == 0 then "Nu" else "År #{d}"

    yAxis = d3.svg.axis().scale(yScale).orient('left').ticks(6)
        .tickFormat (d) -> "#{precisionFormat d}%"

    vis.append("svg:g")
        .attr("transform", "translate(#{GRAPH_MARGINS.xaxis.right},#{height - (GRAPH_MARGINS.bottom - GRAPH_MARGINS.xaxis.down) })")
        .call(xAxis)
        .classed "axis", true

    vis.append("svg:g")
        .attr("transform", "translate(#{ GRAPH_MARGINS.left - GRAPH_MARGINS.yaxis.left}, #{GRAPH_MARGINS.yaxis.down})")
        .call(yAxis)
        .classed "axis", true


onMouseoverLineOrDot = (d, lines) ->
    console.log d3.select(this).attr('range-index')
    if DRAGGING or INACTIVE[+d3.select(this).attr('range-indeẍ́')]
        return false

    for l in lines
        if +l.line.attr('range-index') != +d3.select(this).attr('range-index')
            l.line.attr 'opacity', 0.2
            l.points.attr 'opacity', 0.2

onMouseLeaveLineOrDot = (d, lines) ->
    console.log d3.select(this).attr('range-index')
    if DRAGGING or INACTIVE[+d3.select(this).attr('range-index')]
        return false

    for l in lines
        if not INACTIVE[+l.line.attr('range-index')]
            l.line.attr 'opacity', 1
            l.points.attr 'opacity', 1


$ ->
    $("#generate-result").click () ->
        generateResult randomResult()


    $.getJSON '/data.json', (data) ->

        information = data.information

        vis = d3.select('#graph-visualisation')
        width = vis.attr("width")
        height = vis.attr("height") - 20

        xScale = d3.scale.linear()
            .range([GRAPH_MARGINS.left, width - GRAPH_MARGINS.right]).domain([0,5])

        yScale = d3.scale.linear()
            .range([height - GRAPH_MARGINS.top - GRAPH_MARGINS.bottom, GRAPH_MARGINS.bottom]).domain([0, 5])

        generateBackground vis, width, height, "bars", GRAPH_MARGINS
        generateGraphAxises vis, xScale, yScale, height

        lineGen = d3.svg.line()
            .x (d) -> xScale(d.year)
            .y (d) -> yScale(d.percentage)
            .interpolate('cardinal')

        this.lines = []
        lines = this.lines

        pointDrag = createDrag.call this, yScale, information, lineGen

        for range in information

            line =  vis.append("svg:path")
                .attr 'd', lineGen(range.prediction)
                .attr 'range-index', range.range
                .classed 'line', true
                .attr 'stroke', LINECOLORS[range.range]
                .on 'mouseover', (d) -> onMouseoverLineOrDot.call this, d, lines
                .on 'mouseleave', (d) -> onMouseLeaveLineOrDot.call this, d, lines

            points = vis.selectAll()
                .data range.prediction
                .enter().append('circle')
                .attr 'cx', (d) -> xScale(d.year)
                .attr 'cy', (d) -> yScale(d.percentage)
                .attr 'index', (d) -> range.prediction.indexOf(d)
                .classed "point", true
                .attr 'range-index', range.range
                .attr "r", 8
                .attr 'fill', LINECOLORS[range.range]
                .call(pointDrag)
                .on 'mouseover', (d) -> onMouseoverLineOrDot.call this, d, lines
                .on 'mouseleave', (d) -> onMouseLeaveLineOrDot.call this, d, lines

            lines.push
                line: line
                points: points

        headerItems = d3.select(".graph-header")
            .selectAll()
            .data(information)
            .enter()
            .append('div')
                .classed 'graph-header-item', true

        headerItems.append('div')
            .attr 'range-index', (d) -> d.range
                .classed 'graph-header-btn', true
                .style "background-color", (d) -> LINECOLORS[d.range]
                .on 'click', (d) ->
                    btn = d3.select(this)
                    btn.classed 'inactive', !btn.classed('inactive')
                    if btn.classed 'inactive'
                        index = +btn.attr('range-index')
                        INACTIVE[index] = true
                        l = lines[index]
                        l.line.attr 'opacity', 0.2
                        l.points.attr 'opacity', 0.2

                    else
                        index = +btn.attr('range-index')
                        INACTIVE[index] = false
                        l = lines[index]
                        l.line.attr 'opacity', 1
                        l.points.attr 'opacity', 1


        texts = headerItems.append('p')
            .classed 'graph-header-text', true

        timeParserMany _.pluck(texts.data(), "range"), (err, result) ->
            texts.text (d) -> result[d.range]
