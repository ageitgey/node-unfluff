suite 'DomainExtractor', ->
  domainExtractor = require("../src/domainExtractor")

  test 'exists', ->
    ok domainExtractor

  test 'en.wikipedia.com', ->
  	ok domainExtractor('http://en.wikipedia.org/wiki/Thomas_Edison')

  test 'he.wikipedia.com', ->
    ok domainExtractor('http://he.wikipedia.org/wiki/Thomas_Edison')

  test 'something.he.wikipedia.com', ->
    ok domainExtractor('http://he.wikipedia.org/wiki/Thomas_Edison')