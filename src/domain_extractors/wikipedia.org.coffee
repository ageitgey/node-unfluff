_ = require("lodash")

module.exports =
  image: (doc) ->
    images = doc(".infobox img")

    if images.length > 0 && images.first().attr('src')
      return images.first().attr('src')

  title: (doc) ->
    titleElement = doc("title")
    titleText = titleElement.text()

    return null unless titleElement

    usedDelimeter = false
    _.each ["|", " - ", "»", ":"], (c) ->
      if titleText.indexOf(c) >= 0 && !usedDelimeter
        titlePieces = titleText.split(c)
        titleText = titlePieces[0]
        usedDelimeter = true

    titleText.replace(/�/g, "").trim()