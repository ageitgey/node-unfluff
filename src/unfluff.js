/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let unfluff;
import cheerio from "cheerio";
import extractor from "./extractor";
import cleaner from "./cleaner";

export default unfluff = function(html, language) {
  const doc = cheerio.load(html);
  const lng = language || extractor.lang(doc);

  const pageData = {
    title: extractor.title(doc),
    softTitle: extractor.softTitle(doc),
    date: extractor.date(doc),
    author: extractor.author(doc),
    publisher: extractor.publisher(doc),
    copyright: extractor.copyright(doc),
    favicon: extractor.favicon(doc),
    description: extractor.description(doc),
    keywords: extractor.keywords(doc),
    lang: lng,
    canonicalLink: extractor.canonicalLink(doc),
    tags: extractor.tags(doc),
    image: extractor.image(doc)
  };

  // Step 1: Clean the doc
  cleaner(doc);

  // Step 2: Find the doc node with the best text
  const topNode = extractor.calculateBestNode(doc, lng);

  // Step 3: Extract text, videos, images, links
  pageData.videos = extractor.videos(doc, topNode);
  pageData.links = extractor.links(doc, topNode, lng);
  pageData.text = extractor.text(doc, topNode, lng);

  return pageData;
};

// Allow access to document properties with lazy evaluation
unfluff.lazy = function(html, language) {
  return {
    title() {
      const doc = getParsedDoc.call(this, html);
      return this.title_ != null ? this.title_ : (this.title_ = extractor.title(doc));
    },

    softTitle() {
      const doc = getParsedDoc.call(this, html);
      return this.softTitle_ != null ? this.softTitle_ : (this.softTitle_ = extractor.softTitle(doc));
    },

    date() {
      const doc = getParsedDoc.call(this, html);
      return this.date_ != null ? this.date_ : (this.date_ = extractor.date(doc));
    },

    copyright() {
      const doc = getParsedDoc.call(this, html);
      return this.copyright_ != null ? this.copyright_ : (this.copyright_ = extractor.copyright(doc));
    },

    author() {
      const doc = getParsedDoc.call(this, html);
      return this.author_ != null ? this.author_ : (this.author_ = extractor.author(doc));
    },

    publisher() {
      const doc = getParsedDoc.call(this, html);
      return this.publisher_ != null ? this.publisher_ : (this.publisher_ = extractor.publisher(doc));
    },

    favicon() {
      const doc = getParsedDoc.call(this, html);
      return this.favicon_ != null ? this.favicon_ : (this.favicon_ = extractor.favicon(doc));
    },

    description() {
      const doc = getParsedDoc.call(this, html);
      return this.description_ != null ? this.description_ : (this.description_ = extractor.description(doc));
    },

    keywords() {
      const doc = getParsedDoc.call(this, html);
      return this.keywords_ != null ? this.keywords_ : (this.keywords_ = extractor.keywords(doc));
    },

    lang() {
      const doc = getParsedDoc.call(this, html);
      return this.language_ != null ? this.language_ : (this.language_ = language || extractor.lang(doc));
    },

    canonicalLink() {
      const doc = getParsedDoc.call(this, html);
      return this.canonicalLink_ != null ? this.canonicalLink_ : (this.canonicalLink_ = extractor.canonicalLink(doc));
    },

    tags() {
      const doc = getParsedDoc.call(this, html);
      return this.tags_ != null ? this.tags_ : (this.tags_ = extractor.tags(doc));
    },

    image() {
      const doc = getParsedDoc.call(this, html);
      return this.image_ != null ? this.image_ : (this.image_ = extractor.image(doc));
    },

    videos() {
      if (this.videos_ != null) { return this.videos_; }
      const doc = getCleanedDoc.call(this, html);
      const topNode = getTopNode.call(this, doc, this.lang());
      return this.videos_ = extractor.videos(doc, topNode);
    },

    text() {
      if (this.text_ != null) { return this.text_; }
      const doc = getCleanedDoc.call(this, html);
      const topNode = getTopNode.call(this, doc, this.lang());
      return this.text_ = extractor.text(doc, topNode, this.lang());
    },

    links() {
      if (this.links_ != null) { return this.links_; }
      const doc = getCleanedDoc.call(this, html);
      const topNode = getTopNode.call(this, doc, this.lang());
      return this.links_ = extractor.links(doc, topNode, this.lang());
    }
  };
};

// Load the doc in cheerio and cache it
var getParsedDoc = function(html) {
  return this.doc_ != null ? this.doc_ : (this.doc_ = cheerio.load(html));
};

// Cached version of calculateBestNode
var getTopNode = function(doc, lng) {
  return this.topNode_ != null ? this.topNode_ : (this.topNode_ = extractor.calculateBestNode(doc, lng));
};

// Cached version of the cleaned doc
var getCleanedDoc = function(html) {
  if (this.cleanedDoc_ != null) { return this.cleanedDoc_; }
  const doc = getParsedDoc.call(this, html);
  this.cleanedDoc_ = cleaner(doc);
  return this.cleanedDoc_;
};
