/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import stopwords from '../src/stopwords';

suite('Stop words', function() {

  test('exists', function() {
    const s = stopwords;
    return ok(s);
  });

  test('counts stopwords', function() {
    const data = stopwords('this is silly', 'en');
    eq(data.wordCount, 3);
    eq(data.stopwordCount, 2);
    return arrayEq(data.stopWords, [ 'this', 'is' ]);
});

  test('strips punctuation', function() {
    const data = stopwords('this! is?? silly....', 'en');
    eq(data.wordCount, 3);
    eq(data.stopwordCount, 2);
    return arrayEq(data.stopWords, [ 'this', 'is' ]);
});

  test('defaults to english', function() {
    const data = stopwords('this is fun');
    eq(data.wordCount, 3);
    eq(data.stopwordCount, 2);
    return arrayEq(data.stopWords, [ 'this', 'is' ]);
});

  test('handles spanish', function() {
    const data = stopwords('este es rico', 'es');
    eq(data.wordCount, 3);
    eq(data.stopwordCount, 2);
    return arrayEq(data.stopWords, [ 'este', 'es' ]);
});

  return test('Safely handles a bad language by falling back to english', function() {
    const data = stopwords('this is fun', 'fake-language-to-test-fallbacks');
    eq(data.wordCount, 3);
    eq(data.stopwordCount, 2);
    return arrayEq(data.stopWords, [ 'this', 'is' ]);
});
});
