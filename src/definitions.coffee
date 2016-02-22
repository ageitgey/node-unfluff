# For each field, priority ordered list of selectors
module.exports = definitions = {
  title: [
    {
      elements: ['meta'],
      selectors: ['property', 'name', 'itemprop'],
      filters: ['og:title'],
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
      filters: ['article:published_time'],
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
      filters: ['pubdate', 'publicationDate', 'datepub'],
      attributes: ['content'],
      select:  'first'
    },
    {
      elements: ['meta'],
      selectors: ['name*', 'property*', 'itemprop*'],
      filters: ['_date', '-date', '.date', ':date', 'date_', 'date-'],
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
      selectors: ['itemprop*', 'property*', 'rel*'],
      filters: ['datePublished', 'pubdate', 'publicationDate', 'datepub'],
      select:  'first'
    },
    {
      elements: ['span', 'p', 'div', 'li'],
      selectors: ['class*', 'id*', 'rel*'],
      filters: ['_date', '-date', '.date', ':date', 'date_', 'date-'],
      select:  'first'
    },
    {
      elements: ['time'],
      select: 'first'
    }
  ],
  copyright: [
    {
      elements: ['span', 'p', 'div', 'li'],
      selectors: ['id*', 'class*', 'rel*'],
      filters: ['copyright']
    }
  ],
  publisher: [
    {
      elements: ['meta'],
      selectors: ['property', 'name', 'itemprop'],
      filters: ['og:site_name'],
      attributes: ['content']
    },
    {
      elements: ['meta'],
      selectors: ['name*', 'property*', 'itemprop*'],
      filters: ['publisher'],
      attributes: ['content']
    }
  ],
  author: [
    {
      elements: ['meta'],
      selectors: ['property*', 'name*', 'itemprop*'],
      filters: ['author'],
      attributes: ['content']
    },
    {
      elements: ['meta'],
      selectors: ['property*', 'name*', 'itemprop*'],
      filters: ['dcterms.creator'],
      attributes: ['content']
    },
    {
      elements: ['meta'],
      selectors: ['property*', 'name*', 'itemprop*'],
      filters: ['dc.creator', 'dc:creator'],
      attributes: ['content']
    },
    {
      elements: ['meta'],
      selectors: ['property', 'name', 'itemprop'],
      filters: ['creator'],
      attributes: ['content']
    },
    {
      elements: ['meta'],
      selectors: ['property*', 'name*', 'itemprop*'],
      filters: ['contributor', 'cc:attributionName'],
      attributes: ['content']
    }
  ],
  fallbackAuthor: [
    {
      elements: ['span', 'p', 'div'],
      selectors: ['class*', 'itemprop*'],
      filters: ['author', 'byline', 'instructorName', 'contributor'],
      select: 'first'
    },
    {
      elements: ['a'],
      selectors: ['rel*', 'class*', 'itemprop*'],
      filters: ['author', 'byline', 'instructor', 'contributor'],
      select: 'first'
    },
    {
      elements: ['cite'],
      select: 'first'
    },
    {
      elements: ['span', 'p', 'div'],
      selectors: ['id*'],
      filters: ['author', 'byline', 'instructor', 'contributor'],
      select: 'first'
    },
    {
      elements: ['a'],
      selectors: ['id*'],
      filters: ['author', 'byline', 'instructor', 'contributor'],
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