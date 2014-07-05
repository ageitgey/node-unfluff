suite 'Cleaner', ->
  cleaner = require("../src/cleaner")
  cheerio = require("cheerio")

  test 'exists', ->
    ok cleaner

  test 'removes body classes', ->
    html = fs.readFileSync("./fixtures/test_businessWeek1.html").toString()
    origDoc = cheerio.load(html)

    eq origDoc("body").attr("class").trim(), "magazine"

    newDoc = cleaner(origDoc)
    eq newDoc("body").attr("class"), ''

  test 'removes article attrs', ->
    html = fs.readFileSync("./fixtures/test_gizmodo1.html").toString()
    origDoc = cheerio.load(html)

    eq origDoc("article").attr("class").trim(), "row post js_post_item status-published commented js_amazon_module"

    newDoc = cleaner(origDoc)
    eq newDoc("article").attr("class"), undefined

  test 'removes em tag from image-less ems', ->
    html = fs.readFileSync("./fixtures/test_gizmodo1.html").toString()
    origDoc = cheerio.load(html)

    eq origDoc("em").length, 6

    newDoc = cleaner(origDoc)
    eq newDoc("em").length, 0

  test 'removes scripts', ->
    html = fs.readFileSync("./fixtures/test_businessWeek1.html").toString()
    origDoc = cheerio.load(html)

    eq origDoc("script").length, 40

    newDoc = cleaner(origDoc)
    eq newDoc("script").length, 0

  test 'removes comments', ->
    html = fs.readFileSync("./fixtures/test_gizmodo1.html").toString()
    origDoc = cheerio.load(html)
    comments = origDoc('*').contents().filter () ->
      this.type == "comment"
    eq comments.length, 15

    newDoc = cleaner(origDoc)
    comments = newDoc('*').contents().filter () ->
      this.type == "comment"
    eq comments.length, 0

  test 'replaces childless divs with p tags', ->
    origDoc = cheerio.load("<html><body><div>text1</div></body></html>")
    newDoc = cleaner(origDoc)
    eq newDoc("div").length, 0
    eq newDoc("p").length, 1
    eq newDoc("p").text(), "text1"

  test 'removes divs by re (ex: /caption/)', ->
    html = fs.readFileSync("./fixtures/test_aolNews.html").toString()
    origDoc = cheerio.load(html)
    captions = origDoc('div.caption')
    eq captions.length, 1

    newDoc = cleaner(origDoc)
    captions = newDoc('div.caption')
    eq captions.length, 0

  test 'removes naughty elms by re (ex: /caption/)', ->
    html = fs.readFileSync("./fixtures/test_issue28.html").toString()
    origDoc = cheerio.load(html)
    naughty_els = origDoc('.retweet')
    eq naughty_els.length, 2

    newDoc = cleaner(origDoc)
    naughty_els = newDoc('.retweet')
    eq naughty_els.length, 0
