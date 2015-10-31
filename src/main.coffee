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
        WIDTH = 1000
        HEIGHT = 500
        MARGINS = 
            top: 20
            right: 20
            bottom: 20
            left: 50

        xScale = d3.scale.linear().range([MARGINS.left, WIDTH - MARGINS.right - MARGINS.left]).domain([0,4])
        yScale = d3.scale.linear().range([HEIGHT - MARGINS.top, MARGINS.bottom]).domain([min, max])

        xAxis = d3.svg.axis().scale(xScale)
        yAxis = d3.svg.axis().scale(yScale).orient('left')

        vis.append("svg:g")
            .attr("transform", "translate(0,#{HEIGHT - MARGINS.bottom})") .call(xAxis)

        vis.append("svg:g")
            .attr("transform", "translate(#{ MARGINS.left }, 0)")
            .call(yAxis)

        lineGen = d3.svg.line()
            .x (d) -> xScale(d.year)
            .y (d) -> yScale(d.percentage)
            .interpolate('cardinal')

        line = vis.append("svg:path")
            .attr 'd', lineGen(information["seb"])
            .attr 'stroke', 'green'
            .attr 'stroke-width', 2
            .attr 'fill', 'none'

        drag = d3.behavior.drag()
            .on "dragstart", (d) -> 
                d3.event.sourceEvent.stopPropagation()
                d3.select(this).classed("dragging", true)
            .on "drag", (d) ->
                dot = d3.select(this)
                dot.attr 'cy', d3.event.y
                bank = information[dot.attr("bank")]
                bank[dot.attr("index")] = 
                    year: dot.attr("index")
                    percentage: yScale.invert d3.event.y

                line.attr 'd', lineGen(information["seb"])

            .on "dragend", (d) ->
                d3.select(this).classed("dragging", false)

        vis.selectAll('.dot')
            .data information['seb']
            .enter().append('circle')
            .attr 'cx', (d) -> xScale(d.year)
            .attr 'cy', (d) -> yScale(d.percentage)
            .attr 'index', (d) -> information['seb'].indexOf(d)
            .classed "point", true
            .attr 'bank', "seb"
            .attr "r", 5
            .call(drag)
