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

  test 'returns a soft title chunk without truncation', ->
      doc = cheerio.load("<html><head><title>University Budgets: Where Your Fees Go | Top Universities</title></head></html>")
      title = extractor.softTitle(doc)
      eq title, "University Budgets: Where Your Fees Go"

  test 'prefers the meta tag title', ->
    doc = cheerio.load("<html><head><title>This is my page - mysite</title><meta property=\"og:title\" content=\"Open graph title\"></head></html>")
    title = extractor.title(doc)
    eq title, "Open graph title"

  test 'falls back to title if empty meta tag', ->
    doc = cheerio.load("<html><head><title>This is my page - mysite</title><meta property=\"og:title\" content=\"\"></head></html>")
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

  test 'returns the first title;', ->
    doc = cheerio.load("<html><head><title>This is my page</title></head><svg xmlns=\"http://www.w3.org/2000/svg\"><title>svg title</title></svg></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'handles missing favicons', ->
    doc = cheerio.load("<html><head><title></title></head></html>")
    favicon = extractor.favicon(doc)
    eq undefined, favicon

  test 'returns the article published meta date', ->
    doc = cheerio.load("<html><head><meta property=\"article:published_time\" content=\"2014-10-15T00:01:03+00:00\" /></head></html>")
    date = extractor.date(doc)
    eq date, "2014-10-15T00:01:03+00:00"

  test 'returns the article dublin core meta date', ->
      doc = cheerio.load("<html><head><meta name=\"DC.date.issued\" content=\"2014-10-15T00:01:03+00:00\" /></head></html>")
      date = extractor.date(doc)
      eq date, "2014-10-15T00:01:03+00:00"

  test 'returns the date in the <time> element', ->
    doc = cheerio.load("<html><head></head><body><time>24 May, 2010</time></body></html>")
    date = extractor.date(doc)
    eq date, "24 May, 2010"

  test 'returns the date in the <time> element datetime attribute', ->
    doc = cheerio.load("<html><head></head><body><time datetime=\"2010-05-24T13:47:52+0000\">24 May, 2010</time></body></html>")
    date = extractor.date(doc)
    eq date, "2010-05-24T13:47:52+0000"

  test 'returns nothing if date eq "null"', ->
    doc = cheerio.load("<html><head><meta property=\"article:published_time\" content=\"null\" /></head></html>")
    date = extractor.date(doc)
    eq date, null

  test 'returns the copyright line element', ->
    doc = cheerio.load("<html><head></head><body><div>Some stuff</div><ul><li class='copyright'><!-- // some garbage -->© 2016 The World Bank Group, All Rights Reserved.</li></ul></body></html>")
    copyright = extractor.copyright(doc)
    eq copyright, "2016 The World Bank Group"

  test 'returns the copyright found in the text', ->
    doc = cheerio.load("<html><head></head><body><div>Some stuff</div><ul>© 2016 The World Bank Group, All Rights Reserved\nSome garbage following</li></ul></body></html>")
    copyright = extractor.copyright(doc)
    eq copyright, "2016 The World Bank Group"

  test 'returns nothing if no copyright in the text', ->
    doc = cheerio.load("<html><head></head><body></body></html>")
    copyright = extractor.copyright(doc)
    eq copyright, null

  test 'returns the article published meta author', ->
    doc = cheerio.load("<html><head><meta property=\"article:author\" content=\"Joe Bloggs\" /></head></html>")
    author = extractor.author(doc)
    eq JSON.stringify(author), JSON.stringify(["Joe Bloggs"])

  test 'returns the meta author', ->
    doc = cheerio.load("<html><head><meta property=\"article:author\" content=\"Sarah Smith\" /><meta name=\"author\" content=\"Joe Bloggs\" /></head></html>")
    author = extractor.author(doc)
    eq JSON.stringify(author), JSON.stringify(["Sarah Smith", "Joe Bloggs"])

  test 'returns the named author in the text as fallback', ->
      doc = cheerio.load("<html><head></head><body><span class=\"author\"><a href=\"/author/gary-trust-6318\" class=\"article__author-link\">Gary Trust</a></span></body></html>")
      author = extractor.author(doc)
      eq JSON.stringify(author), JSON.stringify(["Gary Trust"])

  test 'returns the meta author but ignore "null" value', ->
    doc = cheerio.load("<html><head><meta property=\"article:author\" content=\"null\" /><meta name=\"author\" content=\"Joe Bloggs\" /></head></html>")
    author = extractor.author(doc)
    eq JSON.stringify(author), JSON.stringify(["Joe Bloggs"])

  test 'returns the meta publisher', ->
    doc = cheerio.load("<html><head><meta property=\"og:site_name\" content=\"Polygon\" /><meta name=\"author\" content=\"Griffin McElroy\" /></head></html>")
    publisher = extractor.publisher(doc)
    eq publisher, "Polygon"

  test 'returns nothing if publisher eq "null"', ->
    doc = cheerio.load("<html><head><meta property=\"og:site_name\" content=\"null\" /></head></html>")
    publisher = extractor.publisher(doc)
    eq publisher, null

  test 'returns nothing if image eq "null"', ->
    doc = cheerio.load("<html><head><meta property=\"og:image\" content=\"null\" /></head></html>")
    image = extractor.image(doc)
    eq image, null
