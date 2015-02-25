path = require('path')
fs = require('fs')
_ = require('lodash')
{XRegExp} = require('xregexp')

cache = {}

getFilePath = (domain) ->
  path.join(__dirname, "domain_extractors", "#{domain}.coffee")

module.exports = domainExtractors = (url) ->
  domains = extractDomains(url)
  domainExtractor = null
  _.each domains, (domain) ->
    if cache.hasOwnProperty(domain)
      domainExtractor = cache[domain]
    else
      filePath = getFilePath(domain)
      if !fs.existsSync(filePath)
        filePath = null
      else
        domainExtractor = require(filePath)  
        cache[domain] = domainExtractor
  return domainExtractor
  
extractDomains = (url) ->
  domainRegex = XRegExp('[a-zA-Z]*:*//(?<domain>[a-zA-Z0-9\\-\\.]+)/.*')
  domains = []
  domain = XRegExp.replace(url, domainRegex, '${domain}')
  domains.push domain
  splitDomain = domain.split('.')
  # The idea of the subdomain is to try to match wikipedia.org from en.wikipedia.org.
  # So the minimum parts to domain is 2. 
  # Still the length of the text should be bigger then 2 characters, to avoid using only the TLD like co.il
  _.each splitDomain, (subDomain,index) ->
     
    if splitDomain.length - index >= 3 || (splitDomain.length - index == 3 && subDomain.length > 2 )
      domain = domain.substr(subDomain.length+1)
      domains.push domain

  return domains