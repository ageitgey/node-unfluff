
module.exports = function(language) {
  const stepwords = {
    ar: require('./stopwords-ar.json'),
    bg: require('./stopwords-bg.json'),
    cs: require('./stopwords-cs.json'),
    da: require('./stopwords-da.json'),
    de: require('./stopwords-de.json'),
    en: require('./stopwords-en.json'),
    es: require('./stopwords-es.json'),
    fi: require('./stopwords-fi.json'),
    fr: require('./stopwords-fr.json'),
    hu: require('./stopwords-hu.json'),
    id: require('./stopwords-id.json'),
    it: require('./stopwords-it.json'),
    ko: require('./stopwords-ko.json'),
    nb: require('./stopwords-nb.json'),
    nl: require('./stopwords-nl.json'),
    no: require('./stopwords-no.json'),
    pl: require('./stopwords-pl.json'),
    pt: require('./stopwords-pt.json'),
    ru: require('./stopwords-ru.json'),
    sv: require('./stopwords-sv.json'),
    th: require('./stopwords-th.json'),
    tr: require('./stopwords-tr.json'),
    zh: require('./stopwords-zh.json')
  }

  if (stepwords.hasOwnProperty(language)) {
    return stepwords[language].stepwords
  }

  console.error("WARNING: No stopwords found for '" + language + "' - defaulting to English!")
  return stepwords.en.stepwords
}
