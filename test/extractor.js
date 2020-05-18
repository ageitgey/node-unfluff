/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import extractor from '../src/extractor';
import cheerio from 'cheerio';

suite('Extractor', function() {
  test('exists', () => ok(extractor));

  test('returns a blank title', function() {
    const doc = cheerio.load("<html><head><title></title></head></html>");
    const title = extractor.title(doc);
    return eq(title, "");
  });

  test('returns a simple title', function() {
    const doc = cheerio.load("<html><head><title>Hello!</title></head></html>");
    const title = extractor.title(doc);
    return eq(title, "Hello!");
  });

  test('returns a simple title chunk', function() {
    const doc = cheerio.load("<html><head><title>This is my page - mysite</title></head></html>");
    const title = extractor.title(doc);
    return eq(title, "This is my page");
  });

  test('returns a soft title chunk without truncation', function() {
      const doc = cheerio.load("<html><head><title>University Budgets: Where Your Fees Go | Top Universities</title></head></html>");
      const title = extractor.softTitle(doc);
      return eq(title, "University Budgets: Where Your Fees Go");
  });

  test('prefers the meta tag title', function() {
    const doc = cheerio.load("<html><head><title>This is my page - mysite</title><meta property=\"og:title\" content=\"Open graph title\"></head></html>");
    const title = extractor.title(doc);
    return eq(title, "Open graph title");
  });

  test('falls back to title if empty meta tag', function() {
    const doc = cheerio.load("<html><head><title>This is my page - mysite</title><meta property=\"og:title\" content=\"\"></head></html>");
    const title = extractor.title(doc);
    return eq(title, "This is my page");
  });

  test('returns another simple title chunk', function() {
    const doc = cheerio.load("<html><head><title>coolsite.com: This is my page</title></head></html>");
    const title = extractor.title(doc);
    return eq(title, "This is my page");
  });

  test('returns a title chunk without &#65533;', function() {
    const doc = cheerio.load("<html><head><title>coolsite.com: &#65533; This&#65533; is my page</title></head></html>");
    const title = extractor.title(doc);
    return eq(title, "This is my page");
  });

  test('returns the first title;', function() {
    const doc = cheerio.load("<html><head><title>This is my page</title></head><svg xmlns=\"http://www.w3.org/2000/svg\"><title>svg title</title></svg></html>");
    const title = extractor.title(doc);
    return eq(title, "This is my page");
  });

  test('handles missing favicons', function() {
    const doc = cheerio.load("<html><head><title></title></head></html>");
    const favicon = extractor.favicon(doc);
    return eq(undefined, favicon);
  });

  test('returns the article published meta date', function() {
    const doc = cheerio.load("<html><head><meta property=\"article:published_time\" content=\"2014-10-15T00:01:03+00:00\" /></head></html>");
    const date = extractor.date(doc);
    return eq(date, "2014-10-15T00:01:03+00:00");
  });

  test('returns the article dublin core meta date', function() {
      const doc = cheerio.load("<html><head><meta name=\"DC.date.issued\" content=\"2014-10-15T00:01:03+00:00\" /></head></html>");
      const date = extractor.date(doc);
      return eq(date, "2014-10-15T00:01:03+00:00");
  });

  test('returns the date in the <time> element', function() {
    const doc = cheerio.load("<html><head></head><body><time>24 May, 2010</time></body></html>");
    const date = extractor.date(doc);
    return eq(date, "24 May, 2010");
  });

  test('returns the date in the <time> element datetime attribute', function() {
    const doc = cheerio.load("<html><head></head><body><time datetime=\"2010-05-24T13:47:52+0000\">24 May, 2010</time></body></html>");
    const date = extractor.date(doc);
    return eq(date, "2010-05-24T13:47:52+0000");
  });

  test('returns nothing if date eq "null"', function() {
    const doc = cheerio.load("<html><head><meta property=\"article:published_time\" content=\"null\" /></head></html>");
    const date = extractor.date(doc);
    return eq(date, null);
  });

  test('returns the copyright line element', function() {
    const doc = cheerio.load("<html><head></head><body><div>Some stuff</div><ul><li class='copyright'><!-- // some garbage -->© 2016 The World Bank Group, All Rights Reserved.</li></ul></body></html>");
    const copyright = extractor.copyright(doc);
    return eq(copyright, "2016 The World Bank Group");
  });

  test('returns the copyright found in the text', function() {
    const doc = cheerio.load("<html><head></head><body><div>Some stuff</div><ul>© 2016 The World Bank Group, All Rights Reserved\nSome garbage following</li></ul></body></html>");
    const copyright = extractor.copyright(doc);
    return eq(copyright, "2016 The World Bank Group");
  });

  test('returns nothing if no copyright in the text', function() {
    const doc = cheerio.load("<html><head></head><body></body></html>");
    const copyright = extractor.copyright(doc);
    return eq(copyright, null);
  });

  test('returns the article published meta author', function() {
    const doc = cheerio.load("<html><head><meta property=\"article:author\" content=\"Joe Bloggs\" /></head></html>");
    const author = extractor.author(doc);
    return eq(JSON.stringify(author), JSON.stringify(["Joe Bloggs"]));
  });

  test('returns the meta author', function() {
    const doc = cheerio.load("<html><head><meta property=\"article:author\" content=\"Sarah Smith\" /><meta name=\"author\" content=\"Joe Bloggs\" /></head></html>");
    const author = extractor.author(doc);
    return eq(JSON.stringify(author), JSON.stringify(["Sarah Smith", "Joe Bloggs"]));
  });

  test('returns the named author in the text as fallback', function() {
      const doc = cheerio.load("<html><head></head><body><span class=\"author\"><a href=\"/author/gary-trust-6318\" class=\"article__author-link\">Gary Trust</a></span></body></html>");
      const author = extractor.author(doc);
      return eq(JSON.stringify(author), JSON.stringify(["Gary Trust"]));
  });

  test('returns the meta author but ignore "null" value', function() {
    const doc = cheerio.load("<html><head><meta property=\"article:author\" content=\"null\" /><meta name=\"author\" content=\"Joe Bloggs\" /></head></html>");
    const author = extractor.author(doc);
    return eq(JSON.stringify(author), JSON.stringify(["Joe Bloggs"]));
  });

  test('returns the meta publisher', function() {
    const doc = cheerio.load("<html><head><meta property=\"og:site_name\" content=\"Polygon\" /><meta name=\"author\" content=\"Griffin McElroy\" /></head></html>");
    const publisher = extractor.publisher(doc);
    return eq(publisher, "Polygon");
  });

  test('returns nothing if publisher eq "null"', function() {
    const doc = cheerio.load("<html><head><meta property=\"og:site_name\" content=\"null\" /></head></html>");
    const publisher = extractor.publisher(doc);
    return eq(publisher, null);
  });

  return test('returns nothing if image eq "null"', function() {
    const doc = cheerio.load("<html><head><meta property=\"og:image\" content=\"null\" /></head></html>");
    const image = extractor.image(doc);
    return eq(image, null);
  });
});
