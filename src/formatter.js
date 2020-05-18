/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let formatter;
import stopwords from "./stopwords";
import _ from "lodash";
import { XRegExp } from 'xregexp';

export default formatter = function(doc, topNode, language) {
  removeNegativescoresNodes(doc, topNode);
  linksToText(doc, topNode);
  addNewlineToBr(doc, topNode);
  replaceWithText(doc, topNode);
  removeFewwordsParagraphs(doc, topNode, language);
  return convertToText(doc, topNode);
};

var linksToText = function(doc, topNode) {
  const nodes = topNode.find('a');

  return nodes.each(function() {
    return doc(this).replaceWith(doc(this).html());
  });
};

const ulToText = function(doc, node) {
  const nodes = node.find('li');
  let txt = "";

  nodes.each(function() {
    return txt = txt + `\n * ${doc(this).text()}`;
  });

  txt = txt + "\n";
  return txt;
};

var replaceWithText = function(doc, topNode) {
  const nodes = topNode.find('b, strong, i, br, sup');
  return nodes.each(function() {
    return doc(this).replaceWith(doc(this).text());
  });
};

const cleanParagraphText = function(rawText) {
  const txt = rawText.trim();
  txt.replace(/[\s\t]+/g, ' ');
  return txt;
};

// Turn an html element (and children) into nicely formatted text
var convertToText = function(doc, topNode) {
  let txts = [];
  const nodes = topNode.contents();

  // To hold any text fragments that end up in text nodes outside of
  // html elements
  let hangingText = "";

  nodes.each(function() {
    let txt;
    const node = doc(this);
    const nodeType = node[0].type;
    const nodeName = node[0].name;

    // Handle top level text nodes by adding them to a running list
    // and then treating all the hanging nodes as one paragraph tag
    if (nodeType === "text") {
      hangingText += node.text();
      // Same as 'continue'
      return true;
    } else if (nodeName === "ul") {
      hangingText += ulToText(doc, node);
      return true;
    }

    // If we hit a real node and still have extra acculated text,
    // pop it out as if it was a paragraph tag
    if (hangingText.length > 0) {
      txt = cleanParagraphText(hangingText);
      txts = txts.concat(txt.split(/\r?\n/));
      hangingText = "";
    }

    txt = cleanParagraphText(node.text());
    txt = txt.replace(/(\w+\.)([A-Z]+)/, '$1 $2');
    return txts = txts.concat(txt.split(/\r?\n/));
  });

  // Catch any left-over hanging text nodes
  if (hangingText.length > 0) {
    const txt = cleanParagraphText(hangingText);
    txts = txts.concat(txt.split(/\r?\n/));
  }

  txts = _.map(txts, txt => txt.trim());

  // Make sure each text chunk includes at least one text character or number.
  // This supports multiple languages words using XRegExp to generate the
  // regex that matches wranges of unicode characters used in words.
  const regex = XRegExp('[\\p{Number}\\p{Letter}]');
  txts = _.filter(txts, txt => regex.test(txt));

  return txts.join('\n\n');
};

var addNewlineToBr = function(doc, topNode) {
  const brs = topNode.find("br");
  return brs.each(function() {
    const br = doc(this);
    return br.replaceWith("\n\n");
  });
};

// Remove nodes with a negative score because they are probably trash
var removeNegativescoresNodes = function(doc, topNode) {
  const gravityItems = topNode.find("*[gravityScore]");

  return gravityItems.each(function() {
    const item = doc(this);
    const score = parseInt(item.attr('gravityScore')) || 0;

    if (score < 1) {
      return doc(item).remove();
    }
  });
};

// remove paragraphs that have less than x number of words,
// would indicate that it's some sort of link
var removeFewwordsParagraphs = function(doc, topNode, language) {
  const allNodes = topNode.find("*");

  return allNodes.each(function() {
    const el = doc(this);
    const tag = el[0].name;
    const text = el.text();

    const stopWords = stopwords(text, language);
    if (((tag !== 'br') || (text !== '\\r')) && (stopWords.stopwordCount < 3) && (el.find("object").length === 0) && (el.find("embed").length === 0)) {
      return doc(el).remove();
    } else {
      const trimmed = text.trim();
      if ((trimmed[0] === "(") && (trimmed[trimmed.length - 1] === ")")) {
        return doc(el).remove();
      }
    }
  });
};
