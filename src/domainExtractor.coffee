path = require('path')
fs = require('fs')
_ = require('lodash')
{XRegExp} = require('xregexp')

cache = {}

getFilePath = (domain) ->
  path.join(__dirname, "domain_extractors", "#{domain}.coffee")

module.exports = domainExtractors = (url) ->
  domain = extractDomain(url)
  if cache.hasOwnProperty(domain)
    domainExtractor = cache[domain]
  else
    filePath = getFilePath(domain)
    if !fs.existsSync(filePath)
      #console.log("No domainExtractor file found for '#{domain}'")
      filePath = null
      cache[domain] = null
    else
      #console.log("Found domainExtractor file found for '#{domain}'")
      domainExtractor = require(filePath)  
      cache[domain] = domainExtractor
  return domainExtractor
  
extractDomain = (url) ->
  domainRegex = XRegExp('[a-zA-Z]*:*//(?<domain>[a-zA-Z0-9\\-\\.]+)/.*')
  domain = XRegExp.replace(url, domainRegex, '${domain}')