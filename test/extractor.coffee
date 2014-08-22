suite 'Extractor', ->
  extractor = require("../src/extractor")
  cheerio = require("cheerio")

  test 'exists', ->
    ok extractor

  test 'returns a blank title', ->
    doc = cheerio.load("<html><head><title></title></head></html>")
    title = extractor.title(doc)
    eq title, ""

  test 'returns a simple title', ->
    doc = cheerio.load("<html><head><title>Hello!</title></head></html>")
    title = extractor.title(doc)
    eq title, "Hello!"

  test 'returns a simple title chunk', ->
    doc = cheerio.load("<html><head><title>This is my page - mysite</title></head></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'returns another simple title chunk', ->
    doc = cheerio.load("<html><head><title>coolsite.com: This is my page</title></head></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'returns a title chunk without &#65533;', ->
    doc = cheerio.load("<html><head><title>coolsite.com: &#65533; This&#65533; is my page</title></head></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'handles missing favicons', ->
    doc = cheerio.load("<html><head><title></title></head></html>")
    favicon = extractor.favicon(doc)
    eq undefined, favicon
