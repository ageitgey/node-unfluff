/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import _ from "lodash";
import stopwords from "./stopwords";
import formatter from "./formatter";

export default {
  // Grab the date of an html doc
  date(doc) {
    const dateCandidates = doc(`meta[property='article:published_time'], \
meta[itemprop*='datePublished'], meta[name='dcterms.modified'], \
meta[name='dcterms.date'], \
meta[name='DC.date.issued'],  meta[name='dc.date.issued'], \
meta[name='dc.date.modified'], meta[name='dc.date.created'], \
meta[name='DC.date'], \
meta[name='DC.Date'], \
meta[name='dc.date'], \
meta[name='date'], \
time[itemprop*='pubDate'], \
time[itemprop*='pubdate'], \
span[itemprop*='datePublished'], \
span[property*='datePublished'], \
p[itemprop*='datePublished'], \
p[property*='datePublished'], \
div[itemprop*='datePublished'], \
div[property*='datePublished'], \
li[itemprop*='datePublished'], \
li[property*='datePublished'], \
time, \
span[class*='date'], \
p[class*='date'], \
div[class*='date'], \
span[itemprop*='dateModified'], \
span[class*='source'], \
time[itemprop*='datetime']
`);
    return __guard__(cleanNull(__guard__(dateCandidates != null ? dateCandidates.first() : undefined, x1 => x1.attr("content"))), x => x.trim()) || __guard__(cleanNull(__guard__(dateCandidates != null ? dateCandidates.first() : undefined, x3 => x3.attr("datetime"))), x2 => x2.trim()) || cleanText(__guard__(dateCandidates != null ? dateCandidates.first() : undefined, x4 => x4.text())) || null;
  },


  // Grab the copyright line
  copyright(doc) {
    const copyrightCandidates = doc(`p[class*='copyright'], div[class*='copyright'], span[class*='copyright'], li[class*='copyright'], \
p[id*='copyright'], div[id*='copyright'], span[id*='copyright'], li[id*='copyright']`);
    let text = __guard__(copyrightCandidates != null ? copyrightCandidates.first() : undefined, x => x.text());
    if (!text) {
      // try to find the copyright in the text
      text = doc("body").text().replace(/\s*[\r\n]+\s*/g, ". ");
      if (!(text.indexOf("©") > 0)) { return null; }
    }
    const copyright = text.replace(/.*?©(\s*copyright)?([^,;:.|\r\n]+).*/gi, "$2").trim();
    return cleanText(copyright);
  },


  // Grab the author of an html doc
  author(doc) {
    const authorCandidates = doc(`meta[property='article:author'], \
meta[property='og:article:author'], meta[name='author'], \
meta[name='dcterms.creator'], \
meta[name='DC.creator'], \
meta[name='DC.Creator'], \
meta[name='dc.creator'], \
meta[name='creator']`);
    const authorList = [];
    authorCandidates.each(function() {
      const author = __guard__(cleanNull(__guard__(doc(this), x1 => x1.attr("content"))), x => x.trim());
      if (author) {
        return authorList.push(author);
      }
    });
    // fallback to a named author div
    if (authorList.length === 0) {
      const fallbackAuthor = __guard__(doc("span[class*='author']").first(), x => x.text()) || __guard__(doc("p[class*='author']").first(), x1 => x1.text()) || __guard__(doc("div[class*='author']").first(), x2 => x2.text()) || 
      __guard__(doc("span[class*='byline']").first(), x3 => x3.text()) || __guard__(doc("p[class*='byline']").first(), x4 => x4.text()) || __guard__(doc("div[class*='byline']").first(), x5 => x5.text());
      if (fallbackAuthor) {
        authorList.push(cleanText(fallbackAuthor));
      }
    }

    return authorList;
  },


  // Grab the publisher of the page/site
  publisher(doc) {
    const publisherCandidates = doc(`meta[property='og:site_name'], \
meta[name='dc.publisher'], \
meta[name='DC.publisher'], \
meta[name='DC.Publisher']`);
    return __guard__(cleanNull(__guard__(publisherCandidates != null ? publisherCandidates.first() : undefined, x1 => x1.attr("content"))), x => x.trim()) || null;
  },


  // Grab the title of an html doc (excluding junk)
  // Hard-truncates titles containing colon or spaced dash
  title(doc) {
    const titleText = rawTitle(doc);
    return cleanTitle(titleText, ["|", " - ", "»", ":"]);
  },

  // Grab the title with soft truncation
  softTitle(doc) {
    const titleText = rawTitle(doc);
    return cleanTitle(titleText, ["|", " - ", "»"]);
  },


  // Grab the 'main' text chunk
  text(doc, topNode, lang) {
    if (topNode) {
      topNode = postCleanup(doc, topNode, lang);
      return formatter(doc, topNode, lang);
    } else {
      return "";
    }
  },

  // Grab an image for the page
  image(doc) {
    const images = doc(`meta[property='og:image'], \
meta[property='og:image:url'], \
meta[itemprop=image], \
meta[name='twitter:image:src'], \
meta[name='twitter:image'], \
meta[name='twitter:image0']`);

    if ((images.length > 0) && cleanNull(images.first().attr('content'))) {
      return cleanNull(images.first().attr('content'));
    }

    return null;
  },

  // Find any links in the doc
  links(doc, topNode, lang) {
    const links = [];
    const gatherLinks = function(doc, topNode) {
      const nodes = topNode.find('a');
      return nodes.each(function() {
        const href = doc(this).attr('href');
        const text = doc(this).html();
        if (href && text) {
          return links.push({
            text,
            href
          });
        }
      });
    };
      
    if (topNode) {
      topNode = postCleanup(doc, topNode, lang);
      gatherLinks(doc, topNode);
    }
    return links;
  },
      
  // Find any embedded videos in the doc
  videos(doc, topNode) {
    const videoList = [];
    const candidates = doc(topNode).find("iframe, embed, object, video");

    candidates.each(function() {
      const candidate = doc(this);
      const tag = candidate[0].name;

      if (tag === "embed") {
        if (candidate.parent() && (candidate.parent()[0].name === "object")) {
          return videoList.push(getObjectTag(doc, candidate));
        } else {
          return videoList.push(getVideoAttrs(doc, candidate));
        }
      } else if (tag === "object") {
        return videoList.push(getObjectTag(doc, candidate));
      } else if ((tag === "iframe") || (tag === "video")) {
        return videoList.push(getVideoAttrs(doc, candidate));
      }
    });

    // Filter out junky or duplicate videos
    const urls = [];
    const results = [];
    _.each(videoList, function(vid) {
      if (vid && vid.height && vid.width && (urls.indexOf(vid.src) === -1)) {
        results.push(vid);
        return urls.push(vid.src);
      }
    });

    return results;
  },

  // Grab the favicon from an html doc
  favicon(doc) {
    const tag = doc('link').filter(function() {
      return __guard__(doc(this).attr('rel'), x => x.toLowerCase()) === 'shortcut icon';
    });
    return tag.attr('href');
  },

  // Determine the language of an html doc
  lang(doc) {
    // Check the <html> tag
    let l = __guard__(doc("html"), x => x.attr("lang"));

    if (!l) {
      // Otherwise look up for a content-language in meta
      const tag = doc("meta[name=lang]") || doc("meta[http-equiv=content-language]");
      l = tag != null ? tag.attr("content") : undefined;
    }

    if (l) {
      // Just return the 2 letter ISO language code with no country
      const value = l.slice(0, 2);
      if (/^[A-Za-z]{2}$/.test(value)) {
        return value.toLowerCase();
      }
    }

    return null;
  },

  // Get the meta description of an html doc
  description(doc) {
    const tag = doc("meta[name=description], meta[property='og:description']");
    return __guard__(cleanNull(__guard__(tag != null ? tag.first() : undefined, x1 => x1.attr("content"))), x => x.trim());
  },

  // Get the meta keywords of an html doc
  keywords(doc) {
    const tag = doc("meta[name=keywords]");
    return cleanNull(tag != null ? tag.attr("content") : undefined);
  },

  // Get the canonical link of an html doc
  canonicalLink(doc) {
    const tag = doc("link[rel=canonical]");
    return cleanNull(tag != null ? tag.attr("href") : undefined);
  },

  // Get any tags or keywords from an html doc
  tags(doc) {
    let elements = doc("a[rel='tag']");

    if (elements.length === 0) {
      elements = doc("a[href*='/tag/'], a[href*='/tags/'], a[href*='/topic/'], a[href*='?keyword=']");
      if (elements.length === 0) {
        return [];
      }
    }

    const tags = [];
    elements.each(function() {
      const el = doc(this);

      const tag = el.text().trim();
      tag.replace(/[\s\t\n]+/g, '');

      if (tag && (tag.length > 0)) {
        return tags.push(tag);
      }
    });

    return _.uniq(tags);
  },

  // Walk the document's text nodes and find the most 'texty' node in the doc
  calculateBestNode(doc, lang) {
    let topNode = null;
    const nodesToCheck = doc("p, pre, td");

    let startingBoost = 1.0;
    let cnt = 0;
    let i = 0;
    const parentNodes = [];
    const nodesWithText = [];

    // Walk all the p, pre and td nodes
    nodesToCheck.each(function() {
      const node = doc(this);

      const textNode = node.text();
      const wordStats = stopwords(textNode, lang);
      const highLinkDensity = isHighlinkDensity(doc, node);

      // If a node contains multiple common words and isn't just a bunch
      // of links, it's worth consideration of being 'texty'
      if ((wordStats.stopwordCount > 2) && !highLinkDensity) {
        return nodesWithText.push(node);
      }
    });

    const nodesNumber = nodesWithText.length;
    const negativeScoring = 0;
    const bottomNegativescoreNodes = nodesNumber * 0.25;

    // Walk all the potentially 'texty' nodes
    _.each(nodesWithText, function(node) {
      let boostScore = 0.0;

      // If this node has nearby nodes that contain
      // some good text, give the node some boost points
      if (isBoostable(doc, node, lang) === true) {
        if (cnt >= 0) {
          boostScore = (1.0 / startingBoost) * 50;
          startingBoost += 1;
        }
      }

      if (nodesNumber > 15) {
        if ((nodesNumber - i) <= bottomNegativescoreNodes) {
          const booster = bottomNegativescoreNodes - (nodesNumber - i);
          boostScore = -1.0 * Math.pow(booster, 2);
          const negscore = Math.abs(boostScore) + negativeScoring;

          if (negscore > 40) {
            boostScore = 5.0;
          }
        }
      }

      // Give the current node a score of how many common words
      // it contains plus any boost
      const textNode = node.text();
      const wordStats = stopwords(textNode, lang);
      const upscore = Math.floor(wordStats.stopwordCount + boostScore);

      // Propigate the score upwards
      const parentNode = node.parent();
      updateScore(parentNode, upscore);
      updateNodeCount(parentNode, 1);

      if (parentNodes.indexOf(parentNode[0]) === -1) {
        parentNodes.push(parentNode[0]);
      }

      const parentParentNode = parentNode.parent();

      if (parentParentNode) {
        updateNodeCount(parentParentNode, 1);
        updateScore(parentParentNode, upscore / 2);

        if (parentNodes.indexOf(parentParentNode[0]) === -1) {
          parentNodes.push(parentParentNode[0]);
        }
      }

      cnt += 1;
      return i += 1;
    });

    let topNodeScore = 0;

    // Walk each parent and parent-parent and find the one that
    // contains the highest sum score of 'texty' child nodes.
    // That's probably out best node!
    _.each(parentNodes, function(e) {
      const score = getScore(doc(e));

      if (score > topNodeScore) {
        topNode = e;
        topNodeScore = score;
      }

      if (topNode === null) {
        return topNode = e;
      }
    });

    return doc(topNode);
  }
};


var getVideoAttrs = function(doc, node) {
  let data;
  const el = doc(node);
  return data = {
    src: el.attr('src'),
    height: el.attr('height'),
    width: el.attr('width')
  };
};

var getObjectTag = function(doc, node) {
  const srcNode = node.find('param[name=movie]');
  if (!(srcNode.length > 0)) { return null; }

  const src = srcNode.attr("value");
  const video = getVideoAttrs(doc, node);
  video.src = src;
  return video;
};

// Find the biggest chunk of text in the title
const biggestTitleChunk = function(title, splitter) {
  let largeTextLength = 0;
  let largeTextIndex = 0;

  const titlePieces = title.split(splitter);

  // find the largest substring
  _.each(titlePieces, function(piece, i){
    if (piece.length > largeTextLength) {
      largeTextLength = piece.length;
      return largeTextIndex = i;
    }
  });

  return titlePieces[largeTextIndex];
};

// Given a text node, check all previous siblings.
// If the sibling node looks 'texty' and isn't too many
// nodes away, it's probably some yummy text
var isBoostable = function(doc, node, lang) {
  let stepsAway = 0;
  const minimumStopwordCount = 5;
  const maxStepsawayFromNode = 3;

  const nodes = node.prevAll();

  let boostable = false;

  nodes.each(function() {
    const currentNode = doc(this);
    const currentNodeTag = currentNode[0].name;

    if (currentNodeTag === "p") {
      // Make sure the node isn't more than 3 hops away
      if (stepsAway >= maxStepsawayFromNode) {
        boostable = false;
        return false;
      }

      const paraText = currentNode.text();
      const wordStats = stopwords(paraText, lang);

      // Check if the node contains more than 5 common words
      if (wordStats.stopwordCount > minimumStopwordCount) {
        boostable = true;
        return false;
      }

      return stepsAway += 1;
    }
  });

  return boostable;
};

const addSiblings = function(doc, topNode, lang) {
  const baselinescoreSiblingsPara = getSiblingsScore(doc, topNode, lang);
  const sibs = topNode.prevAll();

  sibs.each(function() {
    const currentNode = doc(this);
    const ps = getSiblingsContent(doc, lang, currentNode, baselinescoreSiblingsPara);
    return _.each(ps, p => topNode.prepend(`<p>${p}</p>`));
  });
  return topNode;
};

var getSiblingsContent = function(doc, lang, currentSibling, baselinescoreSiblingsPara) {

  if ((currentSibling[0].name === 'p') && (currentSibling.text().length > 0)) {
    return [currentSibling];
  } else {
    const potentialParagraphs = currentSibling.find("p");
    if (potentialParagraphs === null) {
      return null;
    } else {
      const ps = [];
      potentialParagraphs.each(function() {
        const firstParagraph = doc(this);
        const txt = firstParagraph.text();

        if (txt.length > 0) {
          const wordStats = stopwords(txt, lang);
          const paragraphScore = wordStats.stopwordCount;
          const siblingBaselineScore = 0.30;
          const highLinkDensity = isHighlinkDensity(doc, firstParagraph);
          const score = baselinescoreSiblingsPara * siblingBaselineScore;

          if ((score < paragraphScore) && !highLinkDensity) {
            return ps.push(txt);
          }
        }
      });

      return ps;
    }
  }
};

var getSiblingsScore = function(doc, topNode, lang) {
  let base = 100000;
  let paragraphsNumber = 0;
  let paragraphsScore = 0;
  const nodesToCheck = topNode.find("p");

  nodesToCheck.each(function() {
    const node = doc(this);
    const textNode = node.text();
    const wordStats = stopwords(textNode, lang);
    const highLinkDensity = isHighlinkDensity(doc, node);

    if ((wordStats.stopwordCount > 2) && !highLinkDensity) {
      paragraphsNumber += 1;
      return paragraphsScore += wordStats.stopwordCount;
    }
  });

  if (paragraphsNumber > 0) {
    base = paragraphsScore / paragraphsNumber;
  }

  return base;
};

// Keep track of a node's score with a gravityScore attribute
var updateScore = function(node, addToScore) {
  let currentScore = 0;
  const scoreString = node.attr('gravityScore');
  if (scoreString) {
    currentScore = parseInt(scoreString);
  }

  const newScore = currentScore + addToScore;
  return node.attr("gravityScore", newScore);
};

// Keep track of # of 'texty' child nodes under this node with
// graveityNodes attribute
var updateNodeCount = function(node, addToCount) {
  let currentScore = 0;
  const countString = node.attr('gravityNodes');
  if (countString) {
    currentScore = parseInt(countString);
  }

  const newScore = currentScore + addToCount;
  return node.attr("gravityNodes", newScore);
};

// Check the ratio of links to words in a node.
// If the ratio is high, this node is probably trash.
var isHighlinkDensity = function(doc, node) {
  const links = node.find('a');
  if (!(links.length > 0)) { return false; }

  const txt = node.text();
  const words = txt.split(' ');
  const numberOfWords = words.length;

  const sb = [];
  links.each(function() {
    return sb.push(doc(this).text());
  });

  const linkText = sb.join(' ');
  const linkWords = linkText.split(' ');
  const numberOfLinkWords = linkWords.length;
  const numberOfLinks = links.length;
  const percentLinkWords = numberOfLinkWords / numberOfWords;
  const score = percentLinkWords * numberOfLinks;

  return score >= 1.0;
};

// Return a node's gravity score (amount of texty-ness under it)
var getScore = function(node) {
  const grvScoreString = node.attr('gravityScore');
  if (!grvScoreString) {
    return 0;
  } else {
    return parseInt(grvScoreString);
  }
};


const isTableAndNoParaExist = function(doc, e) {
  const subParagraphs = e.find("p");

  subParagraphs.each(function() {
    const p = doc(this);
    const txt = p.text();

    if (txt.length < 25) {
      return doc(p).remove();
    }
  });

  const subParagraphs2 = e.find("p");
  if ((subParagraphs2.length === 0) && !(["td", "ul", "ol"].includes(e[0].name))) {
    return true;
  } else {
    return false;
  }
};

const isNodescoreThresholdMet = function(doc, node, e) {
  const topNodeScore = getScore(node);
  const currentNodeScore = getScore(e);
  const thresholdScore = topNodeScore * 0.08;

  if ((currentNodeScore < thresholdScore) && !(["td", "ul", "ol", "blockquote"].includes(e[0].name))) {
    return false;
  } else {
    return true;
  }
};

// Remove any remaining trash nodes (clusters of nodes with little/no content)
var postCleanup = function(doc, targetNode, lang) {
  const node = addSiblings(doc, targetNode, lang);

  node.children().each(function() {
    const e = doc(this);
    const eTag = e[0].name;
    if (!['p', 'a'].includes(eTag)) {
      if (isHighlinkDensity(doc, e) || isTableAndNoParaExist(doc, e) || !isNodescoreThresholdMet(doc, node, e)) {
        return doc(e).remove();
      }
    }
  });

  return node;
};

var cleanNull = text => text != null ? text.replace(/^null$/g, "") : undefined;

var cleanText = text => text != null ? text.replace(/[\r\n\t]/g, " ").replace(/\s\s+/g, " ").replace(/<!--.+?-->/g, "").replace(/�/g, "").trim() : undefined;


var cleanTitle = function(title, delimiters) {
  let titleText = title || "";
  let usedDelimeter = false;
  _.each(delimiters, function(c) {
    if ((titleText.indexOf(c) >= 0) && !usedDelimeter) {
      titleText = biggestTitleChunk(titleText, c);
      return usedDelimeter = true;
    }
  });
  return cleanText(titleText);
};


var rawTitle = function(doc) {
  let gotTitle = false;
  let titleText = "";
  // The first h1 or h2 is a useful fallback
  _.each([__guard__(__guard__(doc("meta[property='og:title']"), x1 => x1.first()), x => x.attr("content")), 
  __guard__(__guard__(doc("h1[class*='title']"), x3 => x3.first()), x2 => x2.text()), 
  __guard__(__guard__(doc("title"), x5 => x5.first()), x4 => x4.text()), 
  __guard__(__guard__(doc("h1"), x7 => x7.first()), x6 => x6.text()), 
  __guard__(__guard__(doc("h2"), x9 => x9.first()), x8 => x8.text())], function(candidate) {
    if (candidate && candidate.trim() && !gotTitle) {
      titleText = candidate.trim();
      return gotTitle = true;
    }
  });

  return titleText;
};

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}