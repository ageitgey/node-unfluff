_ = require('lodash')
stopwordsData = require('./stopwordsdata')

cache = {}

# Given a language, loads a list of stop words for that language
# and then returns which of those words exist in the given content
module.exports = stopwords = (content, language = 'en') ->

  stopWords = stopwordsData[ language ]

  if !stopWords
    console.error("WARNING: No stopwords file found for '#{language}' - defaulting to English!")
    stopWords = stopwordsData[ 'en' ]

  if cache.hasOwnProperty(language)
    stopWords = cache[language]
  else
    cache[language] = stopWords

  strippedInput = removePunctuation(content)
  words = candiateWords(strippedInput)
  overlappingStopwords = []

  count = 0

  _.each words, (w) ->
    count += 1
    if stopWords.indexOf(w.toLowerCase()) > -1
      overlappingStopwords.push(w.toLowerCase())

  {
    wordCount: count,
    stopwordCount: overlappingStopwords.length,
    stopWords: overlappingStopwords
  }

removePunctuation = (content) ->
  content.replace(/[\|\@\<\>\[\]\"\'\.,-\/#\?!$%\^&\*\+;:{}=\-_`~()]/g,"")

candiateWords = (strippedInput) ->
  strippedInput.split(' ')
