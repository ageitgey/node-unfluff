suite 'Extractor', ->
  _ = require('underscore')
  extractor = require("../src/extractor")

  checkFixture = (site, fields) ->
    html = fs.readFileSync("./fixtures/test_#{site}.html").toString()
    orig = JSON.parse(fs.readFileSync("./fixtures/test_#{site}.json"))
    data = extractor(html)

    _.each fields, (field) ->
      if field == 'title'
        eq orig.expected.title, data.title #, "#{site}: title didn't match expected value"
      else if field == 'cleaned_text'
        origText = orig.expected.cleaned_text.replace(/\n\n/g, " ")
        newText = data.text.replace(/\n\n/g, " ").replace(/\ \ /g, " ")[0..origText.length-1]
        ok newText, "#{site}: no text was found"
        ok data.text.length >= orig.expected.cleaned_text.length , "#{site}: cleaned text was too short"
        eq origText, newText, "#{site}: cleaned text didn't match expected value"
      else if field == 'link'
        eq orig.expected.final_url, data.canonicalLink, "#{site}: canonical link didn't match expected value"
      else if field == 'image'
        eq orig.expected.image, data.image, "#{site}: image didn't match expected value"
      else if field == 'description'
        eq orig.expected.meta_description, data.description, "#{site}: meta description didn't match expected value"
      else if field == 'lang'
        eq orig.expected.meta_lang, data.lang, "#{site}: detected langauge didn't match expected value"
      else if field == 'keywords'
        eq orig.expected.meta_keywords, data.keywords, "#{site}: meta keywords didn't match expected value"
      else if field == 'favicon'
        eq orig.expected.meta_favicon, data.favicon, "#{site}: favicon url didn't match expected value"
      else if field == 'tags'
        arrayEq orig.expected.tags.sort(), data.tags.sort(), "#{site}: meta tags didn't match expected value"
      else if field == 'videos'
        deepEq orig.expected.movies.sort(), data.videos.sort(), "#{site}: videos didn't match expected value"
      else
        # Oops!
        eq true, false, "#{site}: Invalid test!"

  test 'exists', ->
    ok extractor

  test 'returns a blank title', ->
    data = extractor("<html><head><title></title></head></html>")
    eq data.title, ""

  test 'returns a simple title', ->
    data = extractor("<html><head><title>Hello!</title></head></html>")
    eq data.title, "Hello!"

  test 'returns a simple title chunk', ->
    data = extractor("<html><head><title>This is my page - mysite</title></head></html>")
    eq data.title, "This is my page"

  test 'returns another simple title chunk', ->
    data = extractor("<html><head><title>coolsite.com: This is my page</title></head></html>")
    eq data.title, "This is my page"

  test 'returns a title chunk without &#65533;', ->
    data = extractor("<html><head><title>coolsite.com: &#65533; This&#65533; is my page</title></head></html>")
    eq data.title, "This is my page"

  test 'handles missing favicon', ->
    data = extractor("<html><head><title></title></head></html>")
    eq undefined, data.favicon

  test 'reads favicon', ->
    checkFixture('aolNews' , ['favicon'])

  test 'reads description', ->
    checkFixture('allnewlyrics1' , ['description'])

  test 'reads keywords', ->
    checkFixture('allnewlyrics1' , ['keywords'])

  test 'reads lang', ->
    checkFixture('allnewlyrics1' , ['lang'])

  test 'reads canonical link', ->
    checkFixture('allnewlyrics1' , ['link'])

  test 'reads tags', ->
    checkFixture('tags_kexp' , ['tags'])
    checkFixture('tags_deadline' , ['tags'])
    checkFixture('tags_wnyc' , ['tags'])
    checkFixture('tags_cnet' , ['tags'])
    checkFixture('tags_abcau' , ['tags'])

  test 'reads videos', ->
    checkFixture('embed' , ['videos'])
    checkFixture('iframe' , ['videos'])
    checkFixture('object' , ['videos'])
    checkFixture('polygon_video' , ['videos'])

  test 'images', ->
    checkFixture('aolNews' , ['image'])
    checkFixture('polygon' , ['image'])
    checkFixture('theverge1' , ['image'])


  # TODO: Fix these tests
  # test 'gets cleaned text', ->
  #   checkFixture('elmondo1' , ['cleaned_text'])
  #   checkFixture('lefigaro' , ['cleaned_text'])
  #   checkFixture('aolNews' , ['cleaned_text'])
  #   checkFixture('engadget' , ['cleaned_text'])
  #   checkFixture('marketplace' , ['cleaned_text'])
  #   checkFixture('liberation' , ['cleaned_text'])

  test 'gets cleaned text - Polygon', ->
    checkFixture('polygon' , ['cleaned_text', 'title', 'link', 'description', 'lang', 'favicon'])

  test 'gets cleaned text - The Verge', ->
    checkFixture('theverge1' , ['cleaned_text', 'title', 'link', 'description', 'lang', 'favicon'])

  test 'gets cleaned text - McSweeneys', ->
    checkFixture('mcsweeney', ['cleaned_text', 'link', 'lang', 'favicon'])

  test 'gets cleaned text - CNN', ->
    checkFixture('cnn1' , ['cleaned_text'])

  test 'gets cleaned text - MSN', ->
    checkFixture('msn1' , ['cleaned_text'])

  test 'gets cleaned text - Time', ->
    checkFixture('time2' , ['cleaned_text'])

  test 'gets cleaned text - BI', ->
    checkFixture('businessinsider1' , ['cleaned_text'])
    checkFixture('businessinsider2' , ['cleaned_text'])
    checkFixture('businessinsider3' , ['cleaned_text'])

  test 'gets cleaned text - CNBC', ->
    checkFixture('cnbc1' , ['cleaned_text'])

  test 'gets cleaned text - CBS Local', ->
    checkFixture('cbslocal' , ['cleaned_text'])

  test 'gets cleaned text - Business Week', ->
    checkFixture('businessWeek1' , ['cleaned_text'])
    checkFixture('businessWeek2' , ['cleaned_text'])
    checkFixture('businessWeek3' , ['cleaned_text'])

  test 'gets cleaned text - El Pais', ->
    checkFixture('elpais' , ['cleaned_text'])

  test 'gets cleaned text - Techcrunk', ->
    checkFixture('techcrunch1' , ['cleaned_text'])

  test 'gets cleaned text - Fox "News"', ->
    checkFixture('foxNews' , ['cleaned_text'])

  test 'gets cleaned text - Huff Po', ->
    checkFixture('huffingtonPost2' , ['cleaned_text'])
    checkFixture('testHuffingtonPost' , ['cleaned_text', 'description', 'title'])

  test 'gets cleaned text - ESPN', ->
    checkFixture('espn' , ['cleaned_text'])

  test 'gets cleaned text - Time', ->
    checkFixture('time' , ['cleaned_text'])

  test 'gets cleaned text - CNet', ->
    checkFixture('cnet' , ['cleaned_text'])

  test 'gets cleaned text - Yahoo', ->
    checkFixture('yahoo' , ['cleaned_text'])

  test 'gets cleaned text - Politico', ->
    checkFixture('politico' , ['cleaned_text'])

  test 'gets cleaned text - Goose Regressions', ->
    checkFixture('issue4' , ['cleaned_text'])
    checkFixture('issue24' , ['cleaned_text'])
    checkFixture('issue25' , ['cleaned_text'])
    checkFixture('issue28' , ['cleaned_text'])
    checkFixture('issue32' , ['cleaned_text'])

  test 'gets cleaned text - Gizmodo', ->
    checkFixture('gizmodo1' , ['cleaned_text', 'description', 'keywords'])

  test 'gets cleaned text - Mashable', ->
    checkFixture('mashable_issue_74' , ['cleaned_text'])

  test 'gets cleaned text - USA Today', ->
    checkFixture('usatoday_issue_74' , ['cleaned_text'])
