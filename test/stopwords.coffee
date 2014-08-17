suite 'Stop words', ->
  stopwords = require '../src/stopwords'

  test 'exists', ->
    s = stopwords
    ok s

  test 'counts stopwords', ->
    data = stopwords('this is silly', 'en')
    eq data.wordCount, 3
    eq data.stopwordCount, 2
    arrayEq data.stopWords, [ 'this', 'is' ]

  test 'strips punctuation', ->
    data = stopwords('this! is?? silly....', 'en')
    eq data.wordCount, 3
    eq data.stopwordCount, 2
    arrayEq data.stopWords, [ 'this', 'is' ]

  test 'defaults to english', ->
    data = stopwords('this is fun')
    eq data.wordCount, 3
    eq data.stopwordCount, 2
    arrayEq data.stopWords, [ 'this', 'is' ]

  test 'handles spanish', ->
    data = stopwords('este es rico', 'es')
    eq data.wordCount, 3
    eq data.stopwordCount, 2
    arrayEq data.stopWords, [ 'este', 'es' ]

  test 'Safely handles a bad language by falling back to english', ->
    data = stopwords('this is fun', 'fake-language-to-test-fallbacks')
    eq data.wordCount, 3
    eq data.stopwordCount, 2
    arrayEq data.stopWords, [ 'this', 'is' ]
