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

  test 'replaces u tags with plain text', ->
    origDoc = cheerio.load("<html><body><u>text1</u></body></html>")
    newDoc = cleaner(origDoc)
    eq newDoc("u").length, 0
    eq newDoc("body").html(), "text1"

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

  test 'removes trash line breaks that wouldn\'t be rendered by the browser', ->
    html = fs.readFileSync("./fixtures/test_sec1.html").toString()
    origDoc = cheerio.load(html)
    newDoc = cleaner(origDoc)

    pEls = newDoc('p')
    cleanedParaText = pEls[9].children[0].data
    eq cleanedParaText.trim(), "“This transaction would not only strengthen our global presence, but also demonstrate our commitment to diversify and expand our U.S. commercial portfolio with meaningful new therapies,” said Russell Cox, executive vice president and chief operating officer of Jazz Pharmaceuticals plc. “We look forward to ongoing discussions with the FDA as we continue our efforts toward submission of an NDA for defibrotide in the U.S. Patients in the U.S. with severe VOD have a critical unmet medical need, and we believe that defibrotide has the potential to become an important treatment option for these patients.”"

  test 'inlines code blocks as test', ->
    html = fs.readFileSync("./fixtures/test_github1.html").toString()
    origDoc = cheerio.load(html)
    codeEls = origDoc('code')
    eq codeEls.length, 26

    newDoc = cleaner(origDoc)
    codeEls = newDoc('code')
    eq codeEls.length, 0

    # This is a code block that should still be present in the doc after cleaning
    ok newDoc('body').text().indexOf("extractor = require('unfluff');") > 0
