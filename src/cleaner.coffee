_ = require("lodash")

module.exports = cleaner = (doc) ->
  removeBodyClasses(doc)
  cleanArticleTags(doc)
  cleanEmTags(doc)
  cleanCodeBlocks(doc)
  removeDropCaps(doc)
  removeScriptsStyles(doc)
  cleanBadTags(doc)
  removeNodesRegex(doc, /^caption$/)
  removeNodesRegex(doc, / google /)
  removeNodesRegex(doc, /^[^entry-]more.*$/)
  removeNodesRegex(doc, /[^-]facebook/)
  removeNodesRegex(doc, /facebook-broadcasting/)
  removeNodesRegex(doc, /[^-]twitter/)
  cleanParaSpans(doc)
  cleanUnderlines(doc)
  cleanErrantLinebreaks(doc)
  divToPara(doc, 'div')
  divToPara(doc, 'span')
  return doc

removeBodyClasses = (doc) ->
  doc("body").removeClass()

cleanArticleTags = (doc) ->
  articles = doc("article")
  articles.each () ->
    doc(this).removeAttr('id')
    doc(this).removeAttr('name')
    doc(this).removeAttr('class')

cleanEmTags = (doc) ->
  ems = doc("em")
  ems.each () ->
    images = ems.find("img")
    if images.length == 0
      doc(this).replaceWith(doc(this).html())

cleanCodeBlocks = (doc) ->
  nodes = doc("[class*='highlight-'], pre code, code, pre, ul.task-list")
  nodes.each () ->
    doc(this).replaceWith(doc(this).text())

removeDropCaps = (doc) ->
  nodes = doc("span[class~=dropcap], span[class~=drop_cap]")
  nodes.each () ->
    doc(this).replaceWith(doc(this).html())

removeScriptsStyles = (doc) ->
  doc("script").remove()
  doc("style").remove()

  comments = doc('*').contents().filter () ->
    this.type == "comment"

  doc(comments).remove()

cleanBadTags = (doc) ->
  removeNodesRe = "^side$|combx|retweet|mediaarticlerelated|menucontainer|navbar|storytopbar-bucket|utility-bar|inline-share-tools|comment|PopularQuestions|contact|foot|footer|Footer|footnote|cnn_strycaptiontxt|cnn_html_slideshow|cnn_strylftcntnt|links|meta$|shoutbox|sponsor|tags|socialnetworking|socialNetworking|cnnStryHghLght|cnn_stryspcvbx|^inset$|pagetools|post-attributes|welcome_form|contentTools2|the_answers|communitypromo|runaroundLeft|subscribe|vcard|articleheadings|date|^print$|popup|author-dropdown|tools|socialtools|byline|konafilter|KonaFilter|breadcrumbs|^fn$|wp-caption-text|legende|ajoutVideo|timestamp|js_replies"
  re = new RegExp(removeNodesRe, "i");

  toRemove = doc('*').filter () ->
    doc(this).attr('id')?.match(re) || doc(this).attr('class')?.match(re) || doc(this).attr('name')?.match(re)

  doc(toRemove).remove()

removeNodesRegex = (doc, pattern) ->
  toRemove = doc('div').filter () ->
    doc(this).attr('id')?.match(pattern) || doc(this).attr('class')?.match(pattern)

  doc(toRemove).remove()

cleanParaSpans = (doc) ->
  nodes = doc("p span")
  nodes.each () ->
    doc(this).replaceWith(doc(this).html())

cleanUnderlines = (doc) ->
  nodes = doc("u")
  nodes.each () ->
    doc(this).replaceWith(doc(this).html())

getReplacementNodes = (doc, div) ->
  replacementText = []
  nodesToReturn = []
  nodesToRemove = []
  childs = div.contents()

  childs.each () ->
    kid = doc(this)

    # node is a p
    # and already have some replacement text
    if kid[0].name == 'p' && replacementText.length > 0
      txt = replacementText.join('')
      nodesToReturn.push(txt)
      replacementText = []
      nodesToReturn.push(doc(kid).html())

    # node is a text node
    else if kid[0].type == 'text'
      kidTextNode = kid
      kidText = kid.text()
      replaceText = kidText.replace(/\n/g, "\n\n").replace(/\t/g, "").replace(/^\s+$/g, "")

      if(replaceText.length) > 1
        previousSiblingNode = kidTextNode.prev()

        while previousSiblingNode[0] && previousSiblingNode[0].name == "a" && previousSiblingNode.attr('grv-usedalready') != 'yes'
          outer = " " + doc.html(previousSiblingNode) + " "
          replacementText.push(outer)
          nodesToRemove.push(previousSiblingNode)
          previousSiblingNode.attr('grv-usedalready', 'yes')
          previousSiblingNode = previousSiblingNode.prev()

        replacementText.push(replaceText)

        nextSiblingNode = kidTextNode.next()

        while nextSiblingNode[0] && nextSiblingNode[0].name == "a" && nextSiblingNode.attr('grv-usedalready') != 'yes'
          outer = " " + doc.html(nextSiblingNode) + " "
          replacementText.push(outer)
          nodesToRemove.push(nextSiblingNode)
          nextSiblingNode.attr('grv-usedalready', 'yes')
          previousSiblingNode = nextSiblingNode.next()

    # otherwise
    else
      nodesToReturn.push(doc(kid).html())

  # flush out anything still remaining
  if replacementText.length > 0
    txt = replacementText.join('')
    nodesToReturn.push(txt)
    replacementText = []

  _.each nodesToRemove, (n) ->
    doc(n).remove()

  nodesToReturn

replaceWithPara = (doc, div) ->
  divContent = doc(div).html()
  doc(div).replaceWith("<p>#{divContent}</p>")

divToPara = (doc, domType) ->
  divs = doc(domType)
  lastCount = divs.length + 1

  tags = ['a', 'blockquote', 'dl', 'div', 'img', 'ol', 'p', 'pre', 'table', 'ul']

  divs.each () ->
    div = doc(this)

    items = div.find(tags.join(", "))

    if items.length == 0
      replaceWithPara(doc, this)
    else
      replaceNodes = getReplacementNodes(doc, div)

      html = ""
      _.each replaceNodes, (node) ->
        if node != ''
          html += "<p>#{node}</p>"

      div.empty()
      doc(div).replaceWith("#{html}")

# For plain text nodes directly inside of p tags that contain random single
# line breaks, remove those junky line breaks. They would never be rendered
# by a browser anyway.
cleanErrantLinebreaks = (doc) ->
  doc("p").each () ->
    node = doc(this)
    c = node.contents()

    doc(c).each () ->
      n = doc(this)
      if n[0].type == 'text'
        n.replaceWith(n.text().replace(/([^\n])\n([^\n])/g, "$1 $2"))
