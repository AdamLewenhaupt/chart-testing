(function() {
  $(function() {
    var max, min;
    min = 10000;
    max = 0;
    return $.getJSON('/data.json', function(data) {
      var HEIGHT, MARGINS, WIDTH, bankInfo, drag, information, k, line, lineGen, values, vis, xAxis, xScale, yAxis, yScale;
      information = data;
      for (k in information) {
        bankInfo = information[k];
        values = _.pluck(bankInfo, "percentage");
        max = _.max([_.max(values), max]);
        min = _.min([_.min(values), min]);
      }
      vis = d3.select('#visualisation');
      WIDTH = vis.attr("width");
      HEIGHT = vis.attr("height") - 20;
      MARGINS = {
        top: 20,
        right: 20,
        bottom: 20,
        left: 50
      };
      xScale = d3.scale.linear().range([MARGINS.left, WIDTH - MARGINS.right]).domain([0, 5]);
      yScale = d3.scale.linear().range([HEIGHT - MARGINS.top, MARGINS.bottom]).domain([0, 5]);
      xAxis = d3.svg.axis().scale(xScale).innerTickSize(20).ticks(6).tickFormat(function(d) {
        if (d === 0) {
          return "Nu";
        } else {
          return "År " + d;
        }
      });
      yAxis = d3.svg.axis().scale(yScale).orient('left');
      vis.append("svg:rect").attr("width", WIDTH - (MARGINS.left + MARGINS.right)).attr("height", HEIGHT - (MARGINS.top + MARGINS.bottom)).attr("x", MARGINS.left).attr("y", MARGINS.top).attr("fill", "url(#bars)").on("mousedown", function() {
        return false;
      });
      vis.append("svg:g").attr("transform", "translate(0," + (HEIGHT - MARGINS.bottom) + ")").call(xAxis);
      vis.append("svg:g").attr("transform", "translate(" + MARGINS.left + ", 0)").call(yAxis);
      lineGen = d3.svg.line().x(function(d) {
        return xScale(d.year);
      }).y(function(d) {
        return yScale(d.percentage);
      }).interpolate('cardinal');
      line = vis.append("svg:path").attr('d', lineGen(information["seb"])).classed('line', true);
      drag = d3.behavior.drag().on("dragstart", function(d) {
        d3.event.sourceEvent.stopPropagation();
        return d3.select(this).classed("dragging", true);
      }).on("drag", function(d) {
        var bank, dot;
        dot = d3.select(this);
        dot.attr('cy', d3.event.y);
        bank = information[dot.attr("bank")];
        bank[dot.attr("index")] = {
          year: dot.attr("index"),
          percentage: yScale.invert(d3.event.y)
        };
        return line.attr('d', lineGen(information["seb"]));
      }).on("dragend", function(d) {
        return d3.select(this).classed("dragging", false);
      });
      return vis.selectAll('.dot').data(information['seb']).enter().append('circle').attr('cx', function(d) {
        return xScale(d.year);
      }).attr('cy', function(d) {
        return yScale(d.percentage);
      }).attr('index', function(d) {
        return information['seb'].indexOf(d);
      }).classed("point", true).attr('bank', "seb").attr("r", 8).call(drag);
    });
  });

}).call(this);
