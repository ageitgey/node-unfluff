# For each field, priority ordered list of selectors
# NB wildcard * is still case-sensitive
module.exports = definitions = {
  title: [
    {
      elements: ['meta'],
      selectors: ['property', 'name', 'itemprop'],
      filters: ['og:title', 'dc:title', 'dc:Title', 'DC.title', 'DC.Title'],
      attributes: ['content'],
    },
    {
      elements: ['h1', 'h2'],
      selectors: ['itemprop*', 'class*'],
      filters: ['headline', 'title'],
      select:  'first'
    },
    {
      elements: ['title', 'h1', 'h2'],
      select: 'first'
    }
  ],
  date: [
    {
      elements: ['meta'],
      selectors: ['property', 'name', 'itemprop'],
      filters: ['article:modified_time', 'article:published_time'],
      attributes: ['content'],
      select:  'first'
    },
    {
      elements: ['meta'],
      selectors: ['itemprop*', 'property*', 'name*'],
      filters: ['datePublished'],
      attributes: ['content'],
      select:  'first'
    },
    {
      elements: ['meta'],
      selectors: ['name*', 'property*', 'itemprop*'],
      filters: ['dcterms.modified', 'dcterms.date', 'dcterms:modified', 'dcterms:date'],
      attributes: ['content'],
      select:  'first'
    },
    {
      elements: ['meta'],
      selectors: ['name*', 'property*', 'itemprop*'],
      filters: ['date.issued', 'date.modified', 'date.created', 'dc.date', 'dc:date', 'dc:created'],
      attributes: ['content'],
      select:  'first'
    },
    {
      elements: ['meta'],
      selectors: ['name', 'property', 'itemprop'],
      filters: ['date', 'pubdate', 'pubDate', 'publicationDate'],
      attributes: ['content'],
      select:  'first'
    },
    {
      elements: ['meta'],
      selectors: ['name*', 'property*', 'itemprop*'],
      filters: ['pubdate', 'publicationDate', 'publishdate', 'datepub', 'displaydate', 'lastmod', 'modified',
      'updated', 'created', 'published', 'issued'],
      attributes: ['content'],
      select:  'first'
    },
    {
      elements: ['meta'],
      selectors: ['name*', 'property*', 'itemprop*'],
      filters: ['_date', '-date', '.date', ':date', 'date_', 'date-', 'Date'],
      attributes: ['content'],
      select:  'first'
    },
    {
      elements: ['time'],
      attributes: ['datetime'],
      select:  'first'
    },
    {
      elements: ['time'],
      selectors: ['itemprop*', 'property*', 'rel*'],
      filters: ['date'],
      select:  'first'
    },
    {
      elements: ['span', 'p', 'div', 'li'],
      selectors: ['itemprop*', 'property*', 'class*', 'rel*'],
      filters: ['pubdate', 'publicationDate', 'publishdate', 'datepub', 'displaydate', 'lastmod', 'modified',
      'updated', 'created', 'published', 'issued'],
      select:  'first'
    },
    {
      elements: ['span', 'p', 'div', 'li'],
      selectors: ['itemprop*', 'property*', 'class*', 'id*', 'rel*'],
      filters: ['_date', '-date', '.date', ':date', 'date_', 'date-', 'Date', 'reviewed', 'byline']
    },
    {
      elements: ['time'],
      select:  'first'
    }
  ],
  copyright: [
    {
      elements: ['span', 'p', 'div', 'li'],
      selectors: ['id*', 'class*', 'rel*'],
      filters: ['copyright', 'Copyright'],
      select:  'first'
    }
  ],
  publisher: [
    {
      elements: ['meta'],
      selectors: ['property', 'name', 'itemprop'],
      filters: ['og:site_name'],
      attributes: ['content'],
      select:  'first'
    },
    {
      elements: ['meta'],
      selectors: ['name$', 'property$', 'itemprop$'],
      filters: ['publisher', 'Publisher'],
      attributes: ['content'],
      select:  'first'
    }
  ],
  author: [
    {
      elements: ['meta'],
      selectors: ['property*', 'name*', 'itemprop*'],
      filters: ['dcterms.creator', 'dcterms.Creator'],
      attributes: ['content']
    },
    {
      elements: ['meta'],
      selectors: ['property', 'name', 'itemprop'],
      filters: ['dc.creator', 'dc.Creator', 'DC.creator', 'DC.Creator', 'dc:creator', 'dc:Creator'],
      attributes: ['content']
    },
    {
      elements: ['meta'],
      selectors: ['property', 'name', 'itemprop'],
      filters: ['creator', 'Creator'],
      attributes: ['content']
    },
    {
      elements: ['meta'],
      selectors: ['property*', 'name*', 'itemprop*'],
      filters: ['contributor', 'Contributor', 'attribution', 'Attribution'],
      attributes: ['content']
    },
    {
      elements: ['a'],
      selectors: ['rel*', 'itemprop*'],
      filters: ['byline', 'author', 'instructor', 'contributor', 'attribution', 'Attribution']
    },
    {
      elements: ['meta'],
      selectors: ['property*', 'name*', 'itemprop*'],
      filters: ['author', 'Author'],
      attributes: ['content']
    }
  ],
  fallbackAuthor: [
    {
      elements: ['span'],
      selectors: ['rel*', 'class*', 'itemprop*'],
      filters: ['byline', 'author', 'instructor', 'contributor', 'attribution', 'Attribution'],
      select:  'first'
    },
    {
      elements: ['p', 'div'],
      selectors: ['class*', 'itemprop*'],
      filters: ['byline', 'author', 'instructor', 'contributor'],
      select: 'first'
    },
    {
      elements: ['cite'],
      select: 'first'
    },
    {
      elements: ['span', 'p', 'div'],
      selectors: ['id*'],
      filters: ['byline', 'author', 'instructor', 'contributor'],
      select: 'first'
    },
    {
      elements: ['a'],
      selectors: ['class*', 'id*'],
      filters: ['byline', 'author', 'instructor', 'contributor'],
      select: 'first'
    },
    {
      elements: ['span'],
      selectors: ['itemprop'],
      filters: ['name'],
      select: 'first'
    },
  ]
}