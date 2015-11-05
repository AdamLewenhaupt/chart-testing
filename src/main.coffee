lineColors = [
    "#00CCD6",
    "#FFD900",
    "#FB6648",
    "#FF2321",
    "#FF66CC",
    "#83BF17"
]

$ ->
    $.getJSON '/data.json', (data) ->

        information = data.information

        vis = d3.select('#visualisation')
        WIDTH = vis.attr("width")
        HEIGHT = vis.attr("height") - 20
        MARGINS = 
            top: 20
            right: 20
            bottom: 20
            left: 50

        precisionFormat = d3.format(".1f")

        xScale = d3.scale.linear().range([MARGINS.left, WIDTH - MARGINS.right]).domain([0,5])
        yScale = d3.scale.linear().range([HEIGHT - MARGINS.top, MARGINS.bottom]).domain([0, 5])

        xAxis = d3.svg.axis().scale(xScale).innerTickSize(10).ticks(6).tickFormat (d) -> 
            if d == 0 then "Nu" else "År #{d}"

        yAxis = d3.svg.axis().scale(yScale).orient('left').innerTickSize(10)
            .tickFormat (d) -> "#{precisionFormat d}%"

        vis.append("svg:rect")
            .attr "width", WIDTH - (MARGINS.left + MARGINS.right)
            .attr "height", HEIGHT - (MARGINS.top + MARGINS.bottom)
            .attr "x", MARGINS.left
            .attr "y", MARGINS.top
            .attr "fill", "url(#bars)"
            .on "mousedown", () -> 
                d3.event.preventDefault()
                false
            .on "mousemove", () ->
                d3.event.preventDefault()
                false


        vis.append("svg:g")
            .attr("transform", "translate(0,#{HEIGHT - MARGINS.bottom})") .call(xAxis)
            .classed "axis", true

        vis.append("svg:g")
            .attr("transform", "translate(#{ MARGINS.left }, 0)")
            .call(yAxis)
            .classed "axis", true

        lineGen = d3.svg.line()
            .x (d) -> xScale(d.year)
            .y (d) -> yScale(d.percentage)
            .interpolate('cardinal')

        drag = d3.behavior.drag()
            .on "dragstart", (d) -> 
                d3.event.sourceEvent.stopPropagation()
                d3.select(this).classed("dragging", true)

            .on "drag", (d) ->
                inv = yScale.invert d3.event.y
                dot = d3.select(this)
                inBounds = 0 <= inv <= 5
                if inBounds
                    dot.attr 'cy', d3.event.y    
                    range = _.findWhere(information, { range: +dot.attr('range-index') })

                    range.prediction[dot.attr("index")] = 
                        year: dot.attr("index")
                        percentage: inv

                lines[dot.attr('range-index')].attr 'd', lineGen(range.prediction)

            .on "dragend", (d) ->
                d3.select(this).classed("dragging", false)

        lines = []
        colorCounter = 0

        for range in information

            line =  vis.append("svg:path")
                .attr 'd', lineGen(range.prediction)
                .classed 'line', true
                .attr 'stroke', lineColors[colorCounter]

            lines.push line


            vis.selectAll()
                .data range.prediction
                .enter().append('circle')
                .attr 'cx', (d) -> xScale(d.year)
                .attr 'cy', (d) -> yScale(d.percentage)
                .attr 'index', (d) -> range.prediction.indexOf(d)
                .classed "point", true
                .attr 'range-index', range.range
                .attr "r", 8
                .attr 'fill', lineColors[colorCounter++]
                .call(drag)

        headerItems = d3.select(".graph-header")
            .selectAll()
            .data(information)
            .enter()
            .append('div')
                .classed 'graph-header-item', true

        headerItems.append('div')
                .classed 'graph-header-btn', true
                .style "background-color": (d) -> lineColors[d.range]

        headerItems.append('p')
                .classed 'graph-header-text', true
                .text (d) -> if d.range == 0 then "3 Månader" else "#{d.range} År"
