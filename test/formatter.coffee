suite 'Formatter', ->
  formatter = require("../src/formatter")
  cheerio = require("cheerio")

  test 'exists', ->
    ok formatter

  test 'replaces links with plain text', ->
    html = fs.readFileSync("./fixtures/test_businessWeek1.html").toString()
    origDoc = cheerio.load(html)

    eq origDoc("a").length, 232

    formatter(origDoc, origDoc('body'), 'en')
    eq origDoc("a").length, 0

  test 'doesn\'t drop text nodes accidentally', ->
    html = fs.readFileSync("./fixtures/test_wikipedia1.html").toString()
    doc = cheerio.load(html)

    formatter(doc, doc('body'), 'en')
    html = doc.html()
    # This text was getting dropped by the formatter
    ok /is a thirteen episode anime series directed by Akitaro Daichi and written by Hideyuki Kurata/.test(html)
