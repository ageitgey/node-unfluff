/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let cleaner;
import _ from "lodash";

export default cleaner = function(doc) {
  removeBodyClasses(doc);
  cleanArticleTags(doc);
  cleanEmTags(doc);
  cleanCodeBlocks(doc);
  removeDropCaps(doc);
  removeScriptsStyles(doc);
  cleanBadTags(doc);
  removeNodesRegex(doc, /^caption$/);
  removeNodesRegex(doc, / google /);
  removeNodesRegex(doc, /^[^entry-]more.*$/);
  removeNodesRegex(doc, /[^-]facebook/);
  removeNodesRegex(doc, /facebook-broadcasting/);
  removeNodesRegex(doc, /[^-]twitter/);
  cleanParaSpans(doc);
  cleanUnderlines(doc);
  cleanErrantLinebreaks(doc);
  divToPara(doc, 'div');
  divToPara(doc, 'span');
  return doc;
};

var removeBodyClasses = doc => doc("body").removeClass();

var cleanArticleTags = function(doc) {
  const articles = doc("article");
  return articles.each(function() {
    doc(this).removeAttr('id');
    doc(this).removeAttr('name');
    return doc(this).removeAttr('class');
  });
};

var cleanEmTags = function(doc) {
  const ems = doc("em");
  return ems.each(function() {
    const images = ems.find("img");
    if (images.length === 0) {
      return doc(this).replaceWith(doc(this).html());
    }
  });
};

var cleanCodeBlocks = function(doc) {
  const nodes = doc("[class*='highlight-'], pre code, code, pre, ul.task-list");
  return nodes.each(function() {
    return doc(this).replaceWith(doc(this).text());
  });
};

var removeDropCaps = function(doc) {
  const nodes = doc("span[class~=dropcap], span[class~=drop_cap]");
  return nodes.each(function() {
    return doc(this).replaceWith(doc(this).html());
  });
};

var removeScriptsStyles = function(doc) {
  doc("script").remove();
  doc("style").remove();

  const comments = doc('*').contents().filter(function() {
    return this.type === "comment";
  });

  return doc(comments).remove();
};

var cleanBadTags = function(doc) {
  const removeNodesRe = "^side$|combx|retweet|mediaarticlerelated|menucontainer|navbar|partner-gravity-ad|video-full-transcript|storytopbar-bucket|utility-bar|inline-share-tools|comment|PopularQuestions|contact|foot|footer|Footer|footnote|cnn_strycaptiontxt|cnn_html_slideshow|cnn_strylftcntnt|links|meta$|shoutbox|sponsor|tags|socialnetworking|socialNetworking|cnnStryHghLght|cnn_stryspcvbx|^inset$|pagetools|post-attributes|welcome_form|contentTools2|the_answers|communitypromo|runaroundLeft|subscribe|vcard|articleheadings|date|^print$|popup|author-dropdown|tools|socialtools|byline|konafilter|KonaFilter|breadcrumbs|^fn$|wp-caption-text|legende|ajoutVideo|timestamp|js_replies";
  const re = new RegExp(removeNodesRe, "i");

  const toRemove = doc('*').filter(function() {
    return __guard__(doc(this).attr('id'), x => x.match(re)) || __guard__(doc(this).attr('class'), x1 => x1.match(re)) || __guard__(doc(this).attr('name'), x2 => x2.match(re));
  });

  return doc(toRemove).remove();
};

var removeNodesRegex = function(doc, pattern) {
  const toRemove = doc('div').filter(function() {
    return __guard__(doc(this).attr('id'), x => x.match(pattern)) || __guard__(doc(this).attr('class'), x1 => x1.match(pattern));
  });

  return doc(toRemove).remove();
};

var cleanParaSpans = function(doc) {
  const nodes = doc("p span");
  return nodes.each(function() {
    return doc(this).replaceWith(doc(this).html());
  });
};

var cleanUnderlines = function(doc) {
  const nodes = doc("u");
  return nodes.each(function() {
    return doc(this).replaceWith(doc(this).html());
  });
};

const getReplacementNodes = function(doc, div) {
  let replacementText = [];
  const nodesToReturn = [];
  const nodesToRemove = [];
  const childs = div.contents();

  childs.each(function() {
    const kid = doc(this);

    // node is a p
    // and already have some replacement text
    if ((kid[0].name === 'p') && (replacementText.length > 0)) {
      const txt = replacementText.join('');
      nodesToReturn.push(txt);
      replacementText = [];
      return nodesToReturn.push(doc(kid).html());

    // node is a text node
    } else if (kid[0].type === 'text') {
      const kidTextNode = kid;
      const kidText = kid.text();
      const replaceText = kidText.replace(/\n/g, "\n\n").replace(/\t/g, "").replace(/^\s+$/g, "");

      if((replaceText.length) > 1) {
        let outer;
        let previousSiblingNode = kidTextNode.prev();

        while (previousSiblingNode[0] && (previousSiblingNode[0].name === "a") && (previousSiblingNode.attr('grv-usedalready') !== 'yes')) {
          outer = " " + doc.html(previousSiblingNode) + " ";
          replacementText.push(outer);
          nodesToRemove.push(previousSiblingNode);
          previousSiblingNode.attr('grv-usedalready', 'yes');
          previousSiblingNode = previousSiblingNode.prev();
        }

        replacementText.push(replaceText);

        const nextSiblingNode = kidTextNode.next();

        return (() => {
          const result = [];
          while (nextSiblingNode[0] && (nextSiblingNode[0].name === "a") && (nextSiblingNode.attr('grv-usedalready') !== 'yes')) {
            outer = " " + doc.html(nextSiblingNode) + " ";
            replacementText.push(outer);
            nodesToRemove.push(nextSiblingNode);
            nextSiblingNode.attr('grv-usedalready', 'yes');
            result.push(previousSiblingNode = nextSiblingNode.next());
          }
          return result;
        })();
      }

    // otherwise
    } else {
      return nodesToReturn.push(doc(kid).html());
    }
  });

  // flush out anything still remaining
  if (replacementText.length > 0) {
    const txt = replacementText.join('');
    nodesToReturn.push(txt);
    replacementText = [];
  }

  _.each(nodesToRemove, n => doc(n).remove());

  return nodesToReturn;
};

const replaceWithPara = function(doc, div) {
  const divContent = doc(div).html();
  return doc(div).replaceWith(`<p>${divContent}</p>`);
};

var divToPara = function(doc, domType) {
  const divs = doc(domType);
  const lastCount = divs.length + 1;

  const tags = ['a', 'blockquote', 'dl', 'div', 'img', 'ol', 'p', 'pre', 'table', 'ul'];

  return divs.each(function() {
    const div = doc(this);

    const items = div.find(tags.join(", "));

    if (items.length === 0) {
      return replaceWithPara(doc, this);
    } else {
      const replaceNodes = getReplacementNodes(doc, div);

      let html = "";
      _.each(replaceNodes, function(node) {
        if (node !== '') {
          return html += `<p>${node}</p>`;
        }
      });

      div.empty();
      return doc(div).replaceWith(`${html}`);
    }
  });
};

// For plain text nodes directly inside of p tags that contain random single
// line breaks, remove those junky line breaks. They would never be rendered
// by a browser anyway.
var cleanErrantLinebreaks = doc => doc("p").each(function() {
  const node = doc(this);
  const c = node.contents();

  return doc(c).each(function() {
    const n = doc(this);
    if (n[0].type === 'text') {
      return n.replaceWith(n.text().replace(/([^\n])\n([^\n])/g, "$1 $2"));
    }
  });
});

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}