path = require('path')
fs = require('fs')
_ = require('lodash')

cache = {}

getStopwords = (lang) ->
  switch (lang)
    when 'ar' then require('../data/stopwords/stopwords-ar.txt')
    when 'bg' then require('../data/stopwords/stopwords-bg.txt')
    when 'cs' then require('../data/stopwords/stopwords-cs.txt')
    when 'da' then require('../data/stopwords/stopwords-da.txt')
    when 'de' then require('../data/stopwords/stopwords-de.txt')
    when 'en' then require('../data/stopwords/stopwords-en.txt')
    when 'es' then require('../data/stopwords/stopwords-es.txt')
    when 'fi' then require('../data/stopwords/stopwords-fi.txt')
    when 'fr' then require('../data/stopwords/stopwords-fr.txt')
    when 'hu' then require('../data/stopwords/stopwords-hu.txt')
    when 'id' then require('../data/stopwords/stopwords-id.txt')
    when 'it' then require('../data/stopwords/stopwords-it.txt')
    when 'ko' then require('../data/stopwords/stopwords-ko.txt')
    when 'nb' then require('../data/stopwords/stopwords-nb.txt')
    when 'nl' then require('../data/stopwords/stopwords-nl.txt')
    when 'no' then require('../data/stopwords/stopwords-no.txt')
    when 'pl' then require('../data/stopwords/stopwords-pl.txt')
    when 'pt' then require('../data/stopwords/stopwords-pt.txt')
    when 'ru' then require('../data/stopwords/stopwords-ru.txt')
    when 'sv' then require('../data/stopwords/stopwords-sv.txt')
    when 'th' then require('../data/stopwords/stopwords-th.txt')
    when 'tr' then require('../data/stopwords/stopwords-tr.txt')
    when 'zh' then require('../data/stopwords/stopwords-zh.txt')
    else require('../data/stopwords/stopwords-en.txt')

getFilePath = (language) ->
  path.join(__dirname, "..", "data", "stopwords", "stopwords-#{language}.txt")

# Given a language, loads a list of stop words for that language
# and then returns which of those words exist in the given content
module.exports = stopwords = (content, language = 'en') ->
  hasFs = 'existsSync' in fs

  if hasFs
    filePath = getFilePath(language)

    if !fs.existsSync(filePath)
      console.error("WARNING: No stopwords file found for '#{language}' - defaulting to English!")
      filePath = getFilePath('en')

  if cache.hasOwnProperty(language)
    stopWords = cache[language]
  else if !hasFs
    stopWords = getStopwords(language)
    cache[language] = stopWords
  else
    stopWords = fs.readFileSync(filePath).toString().split('\n')
                  .filter((s) -> s.length > 0)
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
