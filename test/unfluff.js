/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import _ from 'lodash';
import extractor from '../src/unfluff';

suite('Unfluff', function() {
  const cleanTestingText = (text, origTextLength) => text.replace(/\n\n/g, " ").replace(/\ \ /g, " ").slice(0, +(origTextLength-1) + 1 || undefined);

  const cleanOrigText = text => text.replace(/\n\n/g, " ");

  const checkFixture = function(site, fields) {
    const html = fs.readFileSync(`./fixtures/test_${site}.html`).toString();
    const orig = JSON.parse(fs.readFileSync(`./fixtures/test_${site}.json`));
    const data = extractor(html);
    const dataLazy = extractor.lazy(html);

    return _.each(fields, function(field) {
      if (field === 'title') {
        eq(orig.expected.title, data.title, `${site}: title didn't match expected value`);
        return eq(data.title, dataLazy.title());

      } else if (field === 'cleaned_text') {
        const origText = cleanOrigText(orig.expected.cleaned_text);
        const newText = cleanTestingText(data.text, origText.length);
        const partialExtractText = cleanTestingText(dataLazy.text(), origText.length);
        ok(newText, `${site}: no text was found`);
        ok(data.text.length >= orig.expected.cleaned_text.length , `${site}: cleaned text was too short`);
        eq(origText, newText, `${site}: cleaned text didn't match expected value`);
        return eq(origText, partialExtractText, `${site}: cleaned text from partial extract didn't match expected value`);

      } else if (field === 'link') {
        eq(orig.expected.final_url, data.canonicalLink, `${site}: canonical link didn't match expected value`);
        return eq(data.canonicalLink, dataLazy.canonicalLink(), `${site}: canonical link from partial extraction didn't match expected value`);

      } else if (field === 'image') {
        eq(orig.expected.image, data.image, `${site}: image didn't match expected value`);
        return eq(data.image, dataLazy.image(), `${site}: image from partial extraction didn't match expected value`);

      } else if (field === 'description') {
        eq(orig.expected.meta_description, data.description, `${site}: meta description didn't match expected value`);
        return eq(data.description, dataLazy.description(), `${site}: description from partial extraction didn't match expected value`);

      } else if (field === 'lang') {
        eq(orig.expected.meta_lang, data.lang, `${site}: detected langauge didn't match expected value`);
        return eq(data.lang, dataLazy.lang(), `${site}: langauge from partial extraction didn't match expected value`);

      } else if (field === 'keywords') {
        eq(orig.expected.meta_keywords, data.keywords, `${site}: meta keywords didn't match expected value`);
        return eq(data.keywords, dataLazy.keywords(), `${site}: meta keywords from partial extraction didn't match expected value`);

      } else if (field === 'favicon') {
        eq(orig.expected.meta_favicon, data.favicon, `${site}: favicon url didn't match expected value`);
        return eq(data.favicon, dataLazy.favicon(), `${site}: favicon url from partial extraction didn't match expected value`);

      } else if (field === 'tags') {
        const sortedTags = data.tags.sort();
        arrayEq(orig.expected.tags.sort(), sortedTags, `${site}: meta tags didn't match expected value`);
        return arrayEq(sortedTags, dataLazy.tags().sort(), `${site}: meta tags from partial extraction didn't match expected value`);

      } else if (field === 'links') {
        const sortedLinks = data.links.sort();
        const sortedLazyLinks = dataLazy.links().sort();
        if (!orig.expected.links) {
          orig.expected.links = sortedLinks;
          fs.writeFileSync(`./fixtures/test_${site}.json`, JSON.stringify(orig, null, 4));
        }
        deepEq(orig.expected.links.sort(), sortedLinks, `${site}: links didn't match expected value`);
        return deepEq(orig.expected.links.sort(), sortedLazyLinks, `${site}: links from partial extraction didn't match expected value`);

      } else if (field === 'videos') {
        const sortedVideos = data.videos.sort();
        deepEq(orig.expected.movies.sort(), sortedVideos, `${site}: videos didn't match expected value`);
        return deepEq(sortedVideos, dataLazy.videos().sort(), `${site}: videos from partial extraction didn't match expected value`);

      } else {
        // Oops!
        return eq(true, false, `${site}: Invalid test!`);
      }
    });
  };

  test('exists', () => ok(extractor));

  test('lazy version exists', () => ok(extractor.lazy));

  test('reads favicon', () => checkFixture('aolNews' , ['favicon']));

  test('reads description', () => checkFixture('allnewlyrics1' , ['description']));

  test('reads open graph description', () => checkFixture('twitter' , ['description']));

  test('reads keywords', () => checkFixture('allnewlyrics1' , ['keywords']));

  test('reads lang', () => checkFixture('allnewlyrics1' , ['lang']));

  test('reads canonical link', () => checkFixture('allnewlyrics1' , ['link']));

  test('reads tags', function() {
    checkFixture('tags_kexp' , ['tags']);
    checkFixture('tags_deadline' , ['tags']);
    checkFixture('tags_wnyc' , ['tags']);
    checkFixture('tags_cnet' , ['tags']);
    return checkFixture('tags_abcau' , ['tags']);
  });

  test('reads videos', function() {
    checkFixture('embed' , ['videos']);
    checkFixture('iframe' , ['videos']);
    return checkFixture('object' , ['videos']);
  });

  test('links', function() {
    checkFixture('theverge1' , ['links']);
    checkFixture('techcrunch1' , ['links']);
    return checkFixture('polygon' , ['links']);
  });

  test('images', function() {
    checkFixture('aolNews' , ['image']);
    checkFixture('polygon' , ['image']);
    return checkFixture('theverge1' , ['image']);
  });

  test('gets cleaned text - Polygon', () => checkFixture('polygon' , ['cleaned_text', 'title', 'link', 'description', 'lang', 'favicon']));

  test('gets cleaned text - The Verge', () => checkFixture('theverge1' , ['cleaned_text', 'title', 'link', 'description', 'lang', 'favicon']));

  test('gets cleaned tags - The Verge', () => checkFixture('theverge2' , ['tags']));

  test('gets cleaned text - McSweeneys', () => checkFixture('mcsweeney', ['cleaned_text', 'link', 'lang', 'favicon']));

  test('gets cleaned text - CNN', () => checkFixture('cnn1' , ['cleaned_text']));

  test('gets cleaned text - MSN', () => checkFixture('msn1' , ['cleaned_text']));

  test('gets cleaned text - Time', () => checkFixture('time2' , ['cleaned_text']));

  test('gets cleaned text - BI', function() {
    checkFixture('businessinsider1' , ['cleaned_text']);
    checkFixture('businessinsider2' , ['cleaned_text']);
    return checkFixture('businessinsider3' , ['cleaned_text']);
  });

  test('gets cleaned text - CNBC', () => checkFixture('cnbc1' , ['cleaned_text']));

  test('gets cleaned text - CBS Local', () => checkFixture('cbslocal' , ['cleaned_text']));

  test('gets cleaned text - Business Week', function() {
    checkFixture('businessWeek1' , ['cleaned_text']);
    checkFixture('businessWeek2' , ['cleaned_text']);
    return checkFixture('businessWeek3' , ['cleaned_text']);
  });

  test('gets cleaned text - El Pais', () => checkFixture('elpais' , ['cleaned_text']));

  test('gets cleaned text - Techcrunk', () => checkFixture('techcrunch1' , ['cleaned_text']));

  test('gets cleaned text - Fox "News"', () => checkFixture('foxNews' , ['cleaned_text']));

  test('gets cleaned text - Huff Po', function() {
    checkFixture('huffingtonPost2' , ['cleaned_text']);
    return checkFixture('testHuffingtonPost' , ['cleaned_text', 'description', 'title']);
  });

  test('gets cleaned text - ESPN', () => checkFixture('espn' , ['cleaned_text']));

  test('gets cleaned text - Time', () => checkFixture('time' , ['cleaned_text']));

  test('gets cleaned text - CNet', () => checkFixture('cnet' , ['cleaned_text']));

  test('gets cleaned text - Yahoo', () => checkFixture('yahoo' , ['cleaned_text']));

  test('gets cleaned text - Politico', () => checkFixture('politico' , ['cleaned_text']));

  test('gets cleaned text - Goose Regressions', function() {
    checkFixture('issue4' , ['cleaned_text']);
    checkFixture('issue24' , ['cleaned_text']);
    checkFixture('issue25' , ['cleaned_text']);
    return checkFixture('issue28' , ['cleaned_text']);
  });

  test('gets cleaned text - Gizmodo', () => checkFixture('gizmodo1' , ['cleaned_text', 'description', 'keywords']));

  test('gets cleaned text - Mashable', () => checkFixture('mashable_issue_74' , ['cleaned_text']));

  test('gets cleaned text - USA Today', function() {
    checkFixture('usatoday_issue_74' , ['cleaned_text']);
    return checkFixture('usatoday1' , ['cleaned_text']);
  });

  return test('gets cleaned text - dcurt.is', () => checkFixture('dcurtis' , ['cleaned_text']));
});
