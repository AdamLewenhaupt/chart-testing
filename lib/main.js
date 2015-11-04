(function() {
  var lineColors;

  lineColors = ["#00CCD6", "#FFD900", "#FB6648", "#FF2321", "#FF66CC", "#83BF17"];

  $(function() {
    return $.getJSON('/data.json', function(data) {
      var HEIGHT, MARGINS, WIDTH, colorCounter, drag, i, information, len, line, lineGen, lines, precisionFormat, range, results, vis, xAxis, xScale, yAxis, yScale;
      information = data.information;
      vis = d3.select('#visualisation');
      WIDTH = vis.attr("width");
      HEIGHT = vis.attr("height") - 20;
      MARGINS = {
        top: 20,
        right: 20,
        bottom: 20,
        left: 50
      };
      precisionFormat = d3.format(".1f");
      xScale = d3.scale.linear().range([MARGINS.left, WIDTH - MARGINS.right]).domain([0, 5]);
      yScale = d3.scale.linear().range([HEIGHT - MARGINS.top, MARGINS.bottom]).domain([0, 5]);
      xAxis = d3.svg.axis().scale(xScale).innerTickSize(10).ticks(6).tickFormat(function(d) {
        if (d === 0) {
          return "Nu";
        } else {
          return "År " + d;
        }
      });
      yAxis = d3.svg.axis().scale(yScale).orient('left').innerTickSize(10).tickFormat(function(d) {
        return (precisionFormat(d)) + "%";
      });
      vis.append("svg:rect").attr("width", WIDTH - (MARGINS.left + MARGINS.right)).attr("height", HEIGHT - (MARGINS.top + MARGINS.bottom)).attr("x", MARGINS.left).attr("y", MARGINS.top).attr("fill", "url(#bars)").on("mousedown", function() {
        d3.event.preventDefault();
        return false;
      }).on("mousemove", function() {
        d3.event.preventDefault();
        return false;
      });
      vis.append("svg:g").attr("transform", "translate(0," + (HEIGHT - MARGINS.bottom) + ")").call(xAxis).classed("axis", true);
      vis.append("svg:g").attr("transform", "translate(" + MARGINS.left + ", 0)").call(yAxis).classed("axis", true);
      lineGen = d3.svg.line().x(function(d) {
        return xScale(d.year);
      }).y(function(d) {
        return yScale(d.percentage);
      }).interpolate('cardinal');
      drag = d3.behavior.drag().on("dragstart", function(d) {
        d3.event.sourceEvent.stopPropagation();
        return d3.select(this).classed("dragging", true);
      }).on("drag", function(d) {
        var dot, inBounds, inv, range;
        inv = yScale.invert(d3.event.y);
        dot = d3.select(this);
        inBounds = (0 <= inv && inv <= 5);
        if (inBounds) {
          dot.attr('cy', d3.event.y);
          range = _.findWhere(information, {
            range: +dot.attr('range-index')
          });
          range.prediction[dot.attr("index")] = {
            year: dot.attr("index"),
            percentage: inv
          };
        }
        return lines[dot.attr('range-index')].attr('d', lineGen(range.prediction));
      }).on("dragend", function(d) {
        return d3.select(this).classed("dragging", false);
      });
      lines = [];
      colorCounter = 0;
      results = [];
      for (i = 0, len = information.length; i < len; i++) {
        range = information[i];
        line = vis.append("svg:path").attr('d', lineGen(range.prediction)).classed('line', true).attr('stroke', lineColors[colorCounter]);
        lines.push(line);
        results.push(vis.selectAll().data(range.prediction).enter().append('circle').attr('cx', function(d) {
          return xScale(d.year);
        }).attr('cy', function(d) {
          return yScale(d.percentage);
        }).attr('index', function(d) {
          return range.prediction.indexOf(d);
        }).classed("point", true).attr('range-index', range.range).attr("r", 8).attr('fill', lineColors[colorCounter++]).call(drag));
      }
      return results;
    });
  });

}).call(this);
