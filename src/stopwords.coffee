path = require('path')
fs = require('fs')
_ = require('lodash')

cache = {}

getFilePath = (language) ->
  path.join(__dirname, "..", "data", "stopwords", "stopwords-#{language}.txt")

# Given a language, loads a list of stop words for that language
# and then returns which of those words exist in the given content
module.exports = stopwords = (content, language = 'en') ->
  filePath = getFilePath(language)

  if !fs.existsSync(filePath)
    console.error("WARNING: No stopwords file found for '#{language}' - defaulting to English!")
    filePath = getFilePath('en')

  if cache.hasOwnProperty(language)
    stopWords = cache[language]
  else
    stopWords = fs.readFileSync(filePath).toString().split('\n')
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
