(function() {
  var DRAGGING, INACTIVE, LINECOLORS, colorOffset, colorStep, i, j, setPosition;

  colorOffset = 40;

  colorStep = 60;

  LINECOLORS = [];

  for (i = j = 1; j <= 7; i = ++j) {
    LINECOLORS.push("hsl(" + (colorOffset + colorStep * i) + ", 40%, 50%");
  }

  DRAGGING = false;

  INACTIVE = _.map(_.range(7), function(x) {
    return false;
  });

  setPosition = function(x, y, width, height, el) {
    return el.attr("x", x).attr("y", y).attr("width", width).attr("height", height);
  };

  $(function() {
    return $.getJSON('/data.json', function(data) {
      var HEIGHT, MARGINS, WIDTH, colorCounter, drag, headerItems, height, information, k, len, line, lineGen, lines, onMouseoverLineOrDot, oneMouseleaveLineOrDot, points, precisionFormat, range, vis, width, xAxis, xScale, yAxis, yScale;
      information = data.information;
      vis = d3.select('#visualisation');
      WIDTH = vis.attr("width");
      HEIGHT = vis.attr("height") - 20;
      MARGINS = {
        top: 0,
        right: 20,
        bottom: 10,
        left: 50,
        xaxis: {
          right: 5,
          down: 10
        },
        yaxis: {
          left: 5,
          down: 10
        }
      };
      precisionFormat = d3.format(".1f");
      xScale = d3.scale.linear().range([MARGINS.left, WIDTH - MARGINS.right]).domain([0, 5]);
      yScale = d3.scale.linear().range([HEIGHT - MARGINS.top - MARGINS.bottom, MARGINS.bottom]).domain([0, 5]);
      xAxis = d3.svg.axis().scale(xScale).ticks(6).tickFormat(function(d) {
        if (d === 0) {
          return "Nu";
        } else {
          return "År " + d;
        }
      });
      yAxis = d3.svg.axis().scale(yScale).orient('left').ticks(6).tickFormat(function(d) {
        return (precisionFormat(d)) + "%";
      });
      width = WIDTH - (MARGINS.left + MARGINS.right);
      height = HEIGHT - (MARGINS.top + MARGINS.bottom);
      setPosition(MARGINS.left, MARGINS.top, width, height, vis.append("svg:rect")).classed('graph-shadow', true);
      setPosition(MARGINS.left, MARGINS.top, width, height, vis.append("svg:rect")).classed('graph-background', true).attr("fill", "url(#bars)").attr("filter", 'url(#dropshadow)').on("mousedown", function() {
        d3.event.preventDefault();
        return false;
      }).on("mousemove", function() {
        d3.event.preventDefault();
        return false;
      });
      vis.append("svg:g").attr("transform", "translate(" + MARGINS.xaxis.right + "," + (HEIGHT - (MARGINS.bottom - MARGINS.xaxis.down)) + ")").call(xAxis).classed("axis", true);
      vis.append("svg:g").attr("transform", "translate(" + (MARGINS.left - MARGINS.yaxis.left) + ", " + MARGINS.yaxis.down + ")").call(yAxis).classed("axis", true);
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
        DRAGGING = true;
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
        return lines[dot.attr('range-index')].line.attr('d', lineGen(range.prediction));
      }).on("dragend", function(d) {
        DRAGGING = false;
        d3.select(this).classed("dragging", false);
        return oneMouseleaveLineOrDot(d);
      });
      lines = [];
      colorCounter = 0;
      onMouseoverLineOrDot = function(d) {
        var k, l, len, results;
        if (DRAGGING) {
          return false;
        }
        results = [];
        for (k = 0, len = lines.length; k < len; k++) {
          l = lines[k];
          if (+l.line.attr('range-index') !== +d3.select(this).attr('range-index')) {
            l.line.attr('opacity', 0.2);
            results.push(l.points.attr('opacity', 0.2));
          } else {
            results.push(void 0);
          }
        }
        return results;
      };
      oneMouseleaveLineOrDot = function(d) {
        var k, l, len, results;
        if (DRAGGING) {
          return false;
        }
        results = [];
        for (k = 0, len = lines.length; k < len; k++) {
          l = lines[k];
          if (!INACTIVE[+l.line.attr('range-index')]) {
            l.line.attr('opacity', 1);
            results.push(l.points.attr('opacity', 1));
          } else {
            results.push(void 0);
          }
        }
        return results;
      };
      for (k = 0, len = information.length; k < len; k++) {
        range = information[k];
        line = vis.append("svg:path").attr('d', lineGen(range.prediction)).attr('range-index', range.range).classed('line', true).attr('stroke', LINECOLORS[range.range]).on('mouseover', onMouseoverLineOrDot).on('mouseleave', oneMouseleaveLineOrDot);
        points = vis.selectAll().data(range.prediction).enter().append('circle').attr('cx', function(d) {
          return xScale(d.year);
        }).attr('cy', function(d) {
          return yScale(d.percentage);
        }).attr('index', function(d) {
          return range.prediction.indexOf(d);
        }).classed("point", true).attr('range-index', range.range).attr("r", 8).attr('fill', LINECOLORS[range.range]).call(drag).on('mouseover', onMouseoverLineOrDot).on('mouseleave', oneMouseleaveLineOrDot);
        lines.push({
          line: line,
          points: points
        });
      }
      headerItems = d3.select(".graph-header").selectAll().data(information).enter().append('div').classed('graph-header-item', true);
      headerItems.append('div').attr('range-index', function(d) {
        return d.range;
      }).classed('graph-header-btn', true).style("background-color", function(d) {
        return LINECOLORS[d.range];
      }).on('click', function(d) {
        var btn, index, l;
        btn = d3.select(this);
        btn.classed('inactive', !btn.classed('inactive'));
        if (btn.classed('inactive')) {
          index = +btn.attr('range-index');
          INACTIVE[index] = true;
          l = lines[index];
          l.line.attr('opacity', 0.2);
          return l.points.attr('opacity', 0.2);
        } else {
          index = +btn.attr('range-index');
          INACTIVE[index] = false;
          l = lines[index];
          l.line.attr('opacity', 1);
          return l.points.attr('opacity', 1);
        }
      });
      return headerItems.append('p').classed('graph-header-text', true).text(function(d) {
        if (d.range === 0) {
          return "3 mån";
        } else if (d.range < 4) {
          return d.range + " år";
        } else {
          return (d.range + 1) + " år";
        }
      });
    });
  });

}).call(this);
