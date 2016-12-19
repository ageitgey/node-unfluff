function stepwordsJSON(lang) {
  return './stopwords-' + lang + '.json'
};


module.exports = function(language) {
  var words;

  try {
    words = require(stepwordsJSON(language))
  } catch (e) {
    console.error("WARNING: No stopwords found for '" + language + "' - defaulting to English!")
    words = require(stepwordsJSON('en'))
  } finally {
    return words.stepwords
  }
}
