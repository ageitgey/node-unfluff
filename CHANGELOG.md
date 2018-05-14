### 3.0.1
* Removed engine limitaitons in package.json since they no longer are useful.

### 3.0.0
* Updated cheerio dependencies

### 1.0.0
* Add support for extracting out `softTitle`, `date`, `copyright`, `author`, `publisher` thanks to @philgooch. See [#49](https://github.com/ageitgey/node-unfluff/pull/49).

### 0.11.0 
* Add support for pulling the page description out of og:description tags
* Fix a hidden but where unrelated words were joined together when counting number of words in a block of text
* Fixed an issue where page tags were returning line breaks in the tag names for some pages
* Fix issue where an SVG image embedded in the page will have it's title concatenated with the page title
* Updated Portuguese stopwords file

### 0.10.0 
* Fix an issue with junk being left on the page when parsing USA Today news story pages.

### 0.9.0 
* Bulleted lists in a webpage are now retained in the output.

### 0.8.0
* Prefer &lt;meta&gt; og:title tag to &lt;title&gt; element when parsing title of document (Thanks to bradvogel)

### 0.7.0
* Added extractor.lazy() function for lazy access to document properties (Thanks to franza)

### 0.6.1
* Added Thai stopwords (Thanks to thangman22)

### 0.6.0
* If you specify a language that isn't supported, fall back to english and warn the user (Thanks to mhuebert for [#12](https://github.com/ageitgey/node-unfluff/pull/12))

### 0.5.1
* Added Turkish stopwords (Thanks to ayhankuru)

### 0.5.0
* Handle pages with code blocks better (like github pages)

### 0.4.0
* Fix case where text will get dropped accidentally. See [#9](https://github.com/ageitgey/node-unfluff/pull/9).

### 0.3.0
* Better handle html with random line breaks. See [#6](https://github.com/ageitgey/node-unfluff/pull/6).

### 0.2.0
* Added ability to extract an image from articles. See [#4](https://github.com/ageitgey/node-unfluff/pull/4).

### 0.1.0
* Added ability to extract embedded videos from articles. See [#2](https://github.com/ageitgey/node-unfluff/pull/2).

### 0.0.2
* Intial public release

### 0.0.1
* Initial commit
