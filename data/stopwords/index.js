function stopwordsJSON(lang) {
  return './stopwords-' + lang + '.json'
};


module.exports = function(language) {
  var stopwords;

  try {
    stopwords = require(stopwordsJSON(language))
  } catch (e) {
    console.error("WARNING: No stopwords found for '" + language + "' - defaulting to English!")
    stopwords = require(stopwordsJSON('en'))
  } finally {
    return stopwords
  }
}
