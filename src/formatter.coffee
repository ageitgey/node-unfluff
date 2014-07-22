stopwords = require("./stopwords")
_ = require("lodash")
{XRegExp} = require('xregexp')

module.exports = formatter = (doc, topNode, language) ->
  removeNegativescoresNodes(doc, topNode)
  linksToText(doc, topNode)
  addNewlineToBr(doc, topNode)
  replaceWithText(doc, topNode)
  removeFewwordsParagraphs(doc, topNode, language)
  return convertToText(doc, topNode)

linksToText = (doc, topNode) ->
  nodes = topNode.find('a')

  nodes.each () ->
    doc(this).replaceWith(doc(this).html())

replaceWithText = (doc, topNode) ->
  nodes = topNode.find('b, strong, i, br, sup')
  nodes.each () ->
    doc(this).replaceWith(doc(this).text())

cleanParagraphText = (rawText) ->
  txt = rawText.trim()
  txt.replace(/[\s\t]+/g, ' ')
  txt

# Turn an html element (and children) into nicely formatted text
convertToText = (doc, topNode) ->
  txts = []
  nodes = topNode.contents()

  # To hold any text fragments that end up in text nodes outside of
  # html elements
  hangingText = ""

  nodes.each () ->
    node = doc(this)
    nodeType = node[0].type

    # Handle top level text nodes by adding them to a running list
    # and then treating all the hanging nodes as one paragraph tag
    if nodeType == "text"
      hangingText += node.text()
      # Same as 'continue'
      return true

    # If we hit a real node and still have extra acculated text,
    # pop it out as if it was a paragraph tag
    if hangingText.length > 0
      txt = cleanParagraphText(hangingText)
      txts = txts.concat(txt.split(/\r?\n/))
      hangingText = ""

    txt = cleanParagraphText(node.text())
    txts = txts.concat(txt.split(/\r?\n/))

  # Catch any left-over hanging text nodes
  if hangingText.length > 0
    txt = cleanParagraphText(hangingText)
    txts = txts.concat(txt.split(/\r?\n/))

  txts = _.map txts, (txt) ->
    txt.trim()

  # Make sure each text chunk includes at least one text character or number.
  # This supports multiple languages words using XRegExp to generate the
  # regex that matches wranges of unicode characters used in words.
  regex = XRegExp('[\\p{Number}\\p{Letter}]')
  txts = _.filter txts, (txt) ->
    regex.test(txt)

  txts.join('\n\n')

addNewlineToBr = (doc, topNode) ->
  brs = topNode.find("br")
  brs.each () ->
    br = doc(this)
    br.replaceWith("\n\n")

# Remove nodes with a negative score because they are probably trash
removeNegativescoresNodes = (doc, topNode) ->
  gravityItems = topNode.find("*[gravityScore]")

  gravityItems.each () ->
    item = doc(this)
    score = parseInt(item.attr('gravityScore')) || 0

    if score < 1
      doc(item).remove()

# remove paragraphs that have less than x number of words,
# would indicate that it's some sort of link
removeFewwordsParagraphs = (doc, topNode, language) ->
  allNodes = topNode.find("*")

  allNodes.each () ->
    el = doc(this)
    tag = el[0].name
    text = el.text()

    stopWords = stopwords(text, language)
    if (tag != 'br' || text != '\\r') && stopWords.stopwordCount < 3 && el.find("object").length == 0 && el.find("embed").length == 0
      doc(el).remove()
    else
      trimmed = text.trim()
      if trimmed[0] == "(" && trimmed[trimmed.length - 1] == ")"
        doc(el).remove()
