timeParser = (rangeIndex, fn) ->
    if window.timeParserMap == undefined
        $.getJSON '/parsemap.json', (parseMap) ->
            window.timeParserMap = parseMap
            timeParser rangeIndex, fn

    else
        fn null, window.timeParserMap["#{rangeIndex}"]

timeParserMany = (rangeIndices, fn) ->
    async.mapSeries rangeIndices, timeParser, fn
