path = require('path')
fs = require('fs')
_ = require('lodash')
stepwords = require('../data/stopwords/index')

cache = {}

# Given a language, loads a list of stop words for that language
# and then returns which of those words exist in the given content
module.exports = stopwords = (content, language = 'en') ->
  if cache.hasOwnProperty(language)
    stopWords = cache[language]
  else
    stopWords = stepwords(language)
    cache[language] = stopWords

  overlappingStopwords = []

  count = 0

  _.each stopWords, (w) ->
    count += 1
    if stopWords.indexOf(w.toLowerCase()) > -1
      overlappingStopwords.push(w.toLowerCase())

  {
    wordCount: count,
    stopwordCount: overlappingStopwords.length,
    stopWords: overlappingStopwords
  }

