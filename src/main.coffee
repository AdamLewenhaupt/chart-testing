LINECOLORS = [
    "#00CCD6",
    "#FFD900",
    "#FB6648",
    "#FF2321",
    "#FF66CC",
    "#83BF17",
    "#E94C6F"
]

DRAGGING = false

INACTIVE = _.map _.range(7), (x) -> false

setPosition = (x, y, width, height, el) ->
    el.attr "x", x
        .attr "y", y
        .attr "width", width
        .attr "height", height

$ ->
    $.getJSON '/data.json', (data) ->

        information = data.information

        vis = d3.select('#visualisation')
        WIDTH = vis.attr("width")
        HEIGHT = vis.attr("height") - 20
        MARGINS = 
            top: 10
            right: 20
            bottom: 10
            left: 50

        precisionFormat = d3.format(".1f")

        xScale = d3.scale.linear().range([MARGINS.left, WIDTH - MARGINS.right]).domain([0,5])
        yScale = d3.scale.linear().range([HEIGHT - MARGINS.top - MARGINS.bottom, MARGINS.bottom]).domain([0, 5])

        xAxis = d3.svg.axis().scale(xScale).innerTickSize(10).ticks(6).tickFormat (d) -> 
            if d == 0 then "Nu" else "År #{d}"

        yAxis = d3.svg.axis().scale(yScale).orient('left').innerTickSize(10).ticks(6)
            .tickFormat (d) -> "#{precisionFormat d}%"

        width = WIDTH - (MARGINS.left + MARGINS.right)
        height = HEIGHT - (MARGINS.top + MARGINS.bottom)

        setPosition MARGINS.left, MARGINS.top, width, height, vis.append "svg:rect"
            .classed 'graph-shadow', true
            .style "filter", "url(#dropshadow)"

        setPosition MARGINS.left, MARGINS.top, width, height, vis.append("svg:rect")
            .classed 'graph-background', true
            .attr "fill", "url(#bars)"
            .attr "filter", 'url(#dropshadow)'
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

                lines[dot.attr('range-index')].line.attr 'd', lineGen(range.prediction)

            .on "dragend", (d) ->
                DRAGGING = false
                d3.select(this).classed("dragging", false)
                oneMouseleaveLineOrDot d

        lines = []
        colorCounter = 0

        onMouseoverLineOrDot = (d) ->
            if DRAGGING 
                return false

            for l in lines
                if +l.line.attr('range-index') != +d3.select(this).attr('range-index')
                    l.line.attr 'opacity', 0.2
                    l.points.attr 'opacity', 0.2

        oneMouseleaveLineOrDot = (d) ->
            if DRAGGING
                return false

            for l in lines
                if not INACTIVE[+l.line.attr('range-index')]
                    l.line.attr 'opacity', 1
                    l.points.attr 'opacity', 1



        for range in information

            line =  vis.append("svg:path")
                .attr 'd', lineGen(range.prediction)
                .attr 'range-index', range.range
                .classed 'line', true
                .attr 'stroke', LINECOLORS[range.range]
                .on 'mouseover', onMouseoverLineOrDot
                .on 'mouseleave', oneMouseleaveLineOrDot

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
                .call(drag)
                .on 'mouseover', onMouseoverLineOrDot
                .on 'mouseleave', oneMouseleaveLineOrDot

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



        headerItems.append('p')
                .classed 'graph-header-text', true
                .text (d) -> switch d.range
                    when 0
                        "Rörlig ränta"
                    when 1
                        "3 Månader"
                    else
                        "#{d.range - 1} År"
