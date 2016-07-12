cheerio = require("cheerio")
extractor = require("./extractor")
cleaner = require("./cleaner")

module.exports = unfluff = (html, language) ->
  doc = cheerio.load(html)
  lng = language || extractor.lang(doc)

  pageData =
    title: extractor.title(doc)
    softTitle: extractor.softTitle(doc)
    date: extractor.date(doc)
    author: extractor.author(doc)
    publisher: extractor.publisher(doc)
    copyright: extractor.copyright(doc)
    favicon: extractor.favicon(doc)
    description: extractor.description(doc)
    keywords: extractor.keywords(doc)
    lang: lng
    canonicalLink: extractor.canonicalLink(doc)
    tags: extractor.tags(doc)
    image: extractor.image(doc)

  # Step 1: Clean the doc
  cleaner(doc)

  # Step 2: Find the doc node with the best text
  topNode = extractor.calculateBestNode(doc, lng)

  # Step 3: Extract text, videos, images, links
  pageData.videos = extractor.videos(doc, topNode)
  pageData.links = extractor.links(doc, topNode, lng)
  pageData.text = extractor.text(doc, topNode, lng)

  pageData

# Allow access to document properties with lazy evaluation
unfluff.lazy = (html, language) ->
  title: () ->
    doc = getParsedDoc.call(this, html)
    @title_ ?= extractor.title(doc)

  softTitle: () ->
    doc = getParsedDoc.call(this, html)
    @softTitle_ ?= extractor.softTitle(doc)

  date: () ->
    doc = getParsedDoc.call(this, html)
    @date_ ?= extractor.date(doc)

  copyright: () ->
    doc = getParsedDoc.call(this, html)
    @copyright_ ?= extractor.copyright(doc)

  author: () ->
    doc = getParsedDoc.call(this, html)
    @author_ ?= extractor.author(doc)

  publisher: () ->
    doc = getParsedDoc.call(this, html)
    @publisher_ ?= extractor.publisher(doc)

  favicon: () ->
    doc = getParsedDoc.call(this, html)
    @favicon_ ?= extractor.favicon(doc)

  description: () ->
    doc = getParsedDoc.call(this, html)
    @description_ ?= extractor.description(doc)

  keywords: () ->
    doc = getParsedDoc.call(this, html)
    @keywords_ ?= extractor.keywords(doc)

  lang: () ->
    doc = getParsedDoc.call(this, html)
    @language_ ?= language or extractor.lang(doc)

  canonicalLink: () ->
    doc = getParsedDoc.call(this, html)
    @canonicalLink_ ?= extractor.canonicalLink(doc)

  tags: () ->
    doc = getParsedDoc.call(this, html)
    @tags_ ?= extractor.tags(doc)

  image: () ->
    doc = getParsedDoc.call(this, html)
    @image_ ?= extractor.image(doc)

  videos: () ->
    return @videos_ if @videos_?
    doc = getCleanedDoc.call(this, html)
    topNode = getTopNode.call(this, doc, this.lang())
    @videos_ = extractor.videos(doc, topNode)

  text: () ->
    return @text_ if @text_?
    doc = getCleanedDoc.call(this, html)
    topNode = getTopNode.call(this, doc, this.lang())
    @text_ = extractor.text(doc, topNode, this.lang())

  links: () ->
    return @links_ if @links_?
    doc = getCleanedDoc.call(this, html)
    topNode = getTopNode.call(this, doc, this.lang())
    @links_ = extractor.links(doc, topNode, this.lang())

# Load the doc in cheerio and cache it
getParsedDoc = (html) ->
  @doc_ ?= cheerio.load(html)

# Cached version of calculateBestNode
getTopNode = (doc, lng) ->
  @topNode_ ?= extractor.calculateBestNode(doc, lng)

# Cached version of the cleaned doc
getCleanedDoc = (html) ->
  return @cleanedDoc_ if @cleanedDoc_?
  doc = getParsedDoc.call(this, html)
  @cleanedDoc_ = cleaner(doc)
  @cleanedDoc_
