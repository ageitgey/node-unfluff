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
