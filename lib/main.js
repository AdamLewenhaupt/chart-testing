var DRAGGING, GRAPH_MARGINS, INACTIVE, LINECOLORS, RESULT_MARGINS, colorOffset, colorStep, generateAxises, generateBackground, generateChart, generateResult, i, j, randomResult, timeParser, timeParserMany;

timeParser = function(rangeIndex, fn) {
  if (window.timeParserMap === void 0) {
    return $.getJSON('/parsemap.json', function(parseMap) {
      window.timeParserMap = parseMap;
      return timeParser(rangeIndex, fn);
    });
  } else {
    return fn(null, window.timeParserMap["" + rangeIndex]);
  }
};

timeParserMany = function(rangeIndices, fn) {
  return async.mapSeries(rangeIndices, timeParser, fn);
};

colorOffset = 40;

colorStep = 60;

LINECOLORS = [];

for (i = j = 1; j <= 5; i = ++j) {
  LINECOLORS.push("hsl(" + (colorOffset + colorStep * i) + ", 60%, 60%");
}

DRAGGING = false;

INACTIVE = _.map(_.range(5), function(x) {
  return false;
});

GRAPH_MARGINS = {
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

$(function() {
  $("#generate-result").click(function() {
    return generateResult(randomResult());
  });
  return $.getJSON('/data.json', function(data) {
    var HEIGHT, WIDTH, colorCounter, drag, headerItems, height, information, k, len, line, lineGen, lines, onMouseLeaveLineOrDot, onMouseoverLineOrDot, points, precisionFormat, range, texts, vis, width, xAxis, xScale, yAxis, yScale;
    information = data.information;
    vis = d3.select('#graph-visualisation');
    WIDTH = vis.attr("width");
    HEIGHT = vis.attr("height") - 20;
    precisionFormat = d3.format(".1f");
    xScale = d3.scale.linear().range([GRAPH_MARGINS.left, WIDTH - GRAPH_MARGINS.right]).domain([0, 5]);
    yScale = d3.scale.linear().range([HEIGHT - GRAPH_MARGINS.top - GRAPH_MARGINS.bottom, GRAPH_MARGINS.bottom]).domain([0, 5]);
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
    width = WIDTH - (GRAPH_MARGINS.left + GRAPH_MARGINS.right);
    height = HEIGHT - (GRAPH_MARGINS.top + GRAPH_MARGINS.bottom);
    generateBackground(vis, WIDTH, HEIGHT, "bars", GRAPH_MARGINS);
    vis.append("svg:g").attr("transform", "translate(" + GRAPH_MARGINS.xaxis.right + "," + (HEIGHT - (GRAPH_MARGINS.bottom - GRAPH_MARGINS.xaxis.down)) + ")").call(xAxis).classed("axis", true);
    vis.append("svg:g").attr("transform", "translate(" + (GRAPH_MARGINS.left - GRAPH_MARGINS.yaxis.left) + ", " + GRAPH_MARGINS.yaxis.down + ")").call(yAxis).classed("axis", true);
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
        return lines[dot.attr('range-index')].line.attr('d', lineGen(range.prediction));
      }
    }).on("dragend", function(d) {
      DRAGGING = false;
      d3.select(this).classed("dragging", false);
      return onMouseLeaveLineOrDot.apply(this, d);
    });
    lines = [];
    colorCounter = 0;
    onMouseoverLineOrDot = function(d) {
      var k, l, len, results;
      if (DRAGGING || INACTIVE[+d3.select(this).attr('range-indeẍ́')]) {
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
    onMouseLeaveLineOrDot = function(d) {
      var k, l, len, results;
      if (DRAGGING || INACTIVE[+d3.select(this).attr('range-index')]) {
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
      line = vis.append("svg:path").attr('d', lineGen(range.prediction)).attr('range-index', range.range).classed('line', true).attr('stroke', LINECOLORS[range.range]).on('mouseover', onMouseoverLineOrDot).on('mouseleave', onMouseLeaveLineOrDot);
      points = vis.selectAll().data(range.prediction).enter().append('circle').attr('cx', function(d) {
        return xScale(d.year);
      }).attr('cy', function(d) {
        return yScale(d.percentage);
      }).attr('index', function(d) {
        return range.prediction.indexOf(d);
      }).classed("point", true).attr('range-index', range.range).attr("r", 8).attr('fill', LINECOLORS[range.range]).call(drag).on('mouseover', onMouseoverLineOrDot).on('mouseleave', onMouseLeaveLineOrDot);
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
    texts = headerItems.append('p').classed('graph-header-text', true);
    return timeParserMany(_.pluck(texts.data(), "range"), function(err, result) {
      return texts.text(function(d) {
        return result[d.range];
      });
    });
  });
});

RESULT_MARGINS = {
  top: 10,
  bottom: 50,
  left: 70,
  right: 10,
  xaxis: {
    right: -10,
    down: 10
  },
  yaxis: {
    left: 10,
    down: 10
  }
};

generateAxises = function(vis, result, texts, width, height) {
  var xAxis, xScale, yAxis, yScale;
  xScale = d3.scale.linear().domain([0, 100]).range([RESULT_MARGINS.left, width - RESULT_MARGINS.right]);
  yScale = d3.scale.linear().domain([0, result.length]).range([height - RESULT_MARGINS.top, RESULT_MARGINS.bottom]);
  xAxis = d3.svg.axis().scale(xScale).tickFormat(function(d) {
    return d + "%";
  });
  yAxis = d3.svg.axis().scale(yScale).orient('left').ticks(result.length).tickFormat(function(d) {
    return texts[d - 1];
  });
  vis.append("svg:g").attr("transform", "translate(" + RESULT_MARGINS.xaxis.right + "," + (height - (RESULT_MARGINS.bottom - RESULT_MARGINS.xaxis.down)) + ")").call(xAxis).classed('axis', true);
  vis.append("svg:g").attr("transform", "translate(" + (RESULT_MARGINS.left - RESULT_MARGINS.yaxis.left) + ", " + (RESULT_MARGINS.yaxis.down + RESULT_MARGINS.top) + ")").call(yAxis).classed('axis', true);
  return xScale;
};

generateBackground = function(vis, width, height, background, margins) {
  return vis.append('svg:rect').classed('graph-background', true).attr("fill", "url(#" + background + ")").attr("filter", "url(#dropshadow)").attr("width", width - margins.left - margins.right).attr("height", height - margins.bottom - margins.top).attr('x', margins.left).attr('y', margins.top).on("mousedown", function() {
    d3.event.preventDefault();
    return false;
  }).on("mousemove", function() {
    d3.event.preventDefault();
    return false;
  });
};

generateChart = function(vis, result, width, height, xScale) {
  return vis.append('svg:g').selectAll('rect').data(result).enter().append('svg:rect').attr('height', (height - RESULT_MARGINS.bottom - RESULT_MARGINS.top) / result.length).attr('width', function(d) {
    return xScale(d.dist);
  }).attr('x', RESULT_MARGINS.left).attr('y', function(d, i) {
    return RESULT_MARGINS.top + i * (height - RESULT_MARGINS.bottom - RESULT_MARGINS.top) / result.length;
  }).attr('fill', function(d) {
    return LINECOLORS[d.range];
  }).attr('width', function(d) {
    return (width - RESULT_MARGINS.left - RESULT_MARGINS.right) * d.dist;
  });
};

generateResult = function(result) {
  var height, vis, width;
  vis = d3.select('#result-visualisation');
  vis.selectAll('g').remove();
  width = vis.attr('width');
  height = vis.attr('height');
  return timeParserMany(_.pluck(result, "range"), function(err, texts) {
    var xScale;
    xScale = generateAxises(vis, result, texts, width, height);
    if (vis.selectAll('.graph-background').empty()) {
      generateBackground(vis, width, height, "bars-vertical", RESULT_MARGINS);
    }
    return generateChart(vis, result, width, height, xScale);
  });
};

randomResult = function() {
  var itr, ranges, sample, spawn;
  ranges = Math.floor((Math.random() * 4) + 1);
  sample = _.sample([0, 1, 2, 3, 4], ranges);
  itr = function(memo, num) {
    var d;
    d = Math.min((Math.random() + 0.11) * (1 - memo.acc), 1);
    if (d > 0.1) {
      memo.l.push({
        range: "" + num,
        dist: d
      });
      memo.acc = memo.acc + d;
    }
    return memo;
  };
  spawn = _.reduce(sample, itr, {
    l: [],
    acc: 0
  });
  spawn.l[0].dist += 1 - spawn.acc;
  return spawn.l;
};

$(function() {
  var result;
  result = randomResult();
  return generateResult(result);
});
