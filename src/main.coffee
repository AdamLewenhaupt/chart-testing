$ ->
    min = 10000
    max = 0


    $.getJSON '/data.json', (data) ->
        information = data

        for k, bankInfo of information
            values = _.pluck(bankInfo, "percentage")            
            max = _.max [_.max(values), max]
            min = _.min [_.min(values), min]

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
            .on "mousedown", () -> false

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

        line = vis.append("svg:path")
            .attr 'd', lineGen(information["seb"])
            .classed 'line', true

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
                    bank = information[dot.attr("bank")]
                    bank[dot.attr("index")] = 
                        year: dot.attr("index")
                        percentage: inv

                line.attr 'd', lineGen(information["seb"])

            .on "dragend", (d) ->
                d3.select(this).classed("dragging", false)

        vis.selectAll()
            .data information['seb']
            .enter().append('circle')
            .attr 'cx', (d) -> xScale(d.year)
            .attr 'cy', (d) -> yScale(d.percentage)
            .attr 'index', (d) -> information['seb'].indexOf(d)
            .classed "point", true
            .attr 'bank', "seb"
            .attr "r", 8
            .call(drag)
