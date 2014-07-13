stopwords = require("./stopwords")
_ = require("lodash")

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

# Turn an html element (and children) into nicely formatted text
convertToText = (doc, topNode) ->
  txts = []
  nodes = topNode.children()
  nodes.each () ->
    node = doc(this)

    txt = node.text().trim()
    txt.replace(/[\s\t]+/g, ' ')
    txts = txts.concat(txt.split(/\r?\n/))

  txts = _.map txts, (txt) ->
    txt.trim()

  txts = _.filter txts, (txt) ->
    (/[a-zA-Z0-9]/.test(txt))

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
