# unfluff

An automatic web page content extractor for Node.js!

Automatically grab the main
text out of a webpage like this:

```
extractor = require('unfluff');
data = extractor(my_html_data);
console.log(data.text);
```

In other words, it turns pretty webpages into boring plain text/json data:

![](https://cloud.githubusercontent.com/assets/896692/3478577/b82f39cc-033d-11e4-9e68-226c9a7bc1c0.jpg)

This might be useful for:
- Writing your own Instapaper clone
- Easily building ML data sets from web pages
- Reading your favorite articles from the console?

Please don't use this for:
- Stealing other peoples' web pages
- Making crappy spam sites with stolen content from other sites
- Being a jerk

## Credits / Thanks

This library is largely based on [python-goose](https://github.com/grangier/python-goose)
by [Xavier Grangier](https://github.com/grangier) which is in turn based on [goose](https://github.com/GravityLabs/goose)
by [Gravity Labs](https://github.com/GravityLabs). However, it's not an exact
port so it may behave differently on some pages and the feature set is a little
bit different.  If you are looking for a python or Scala/Java/JVM solution,
check out those libraries!

## Install

    npm install --save unfluff

## Usage

You can use `unfluff` from node or right on the command line!

### Extracted data elements

This is what `unfluff` will try to grab from a web page:
- `title` - The document's title (from the &lt;title&gt; tag)
- `text` - The main text of the document with all the junk thrown away
- `tags`- Any tags or keywords that could be found by checking &lt;rel&gt; tags or by looking at href urls.
- `canonicalLink` - The [canonical url](https://support.google.com/webmasters/answer/139066?hl=en) of the document, if given.
- `lang` - The language of the document, either detected or supplied by you.
- `description` - The description of the document, from &lt;meta&gt; tags
- `favicon` - The url of the document's [favicon](http://en.wikipedia.org/wiki/Favicon).

This is returned as a simple json object.

### Command line interface

You can pass a webpage to unfluff and it will try to parse out the interesting
bits.

You can either pass in a file name:

```
unfluff my_file.html
```

Or you can pipe it in:

```
curl -s "http://somesite.com/page" | unfluff
```

You can easily chain this together with other unix commands to do cool stuff.
For example, you can download a web page, parse it and then use
[jq](http://stedolan.github.io/jq/) to print it just the body text.

```
curl -s "http://www.polygon.com/2014/6/26/5842180/shovel-knight-review-pc-3ds-wii-u" | unfluff | jq -r .text
```

And here's how to find the top 10 most common words in an article:

```
curl -s "http://www.polygon.com/2014/6/26/5842180/shovel-knight-review-pc-3ds-wii-u" | unfluff |  tr -c '[:alnum:]' '[\n*]' | sort | uniq -c | sort -nr | head -10
```

### Module Interface

#### `extractor(html, language)`

html: The html you want to parse

language (optional): The document's two-letter language code. This will be
auto-detected as best as possible, but there might be cases where you want to
override it.

The extraction algorithm depends heavily on the language, so it probably won't work
if you have the language set incorrectly.

```javascript
extractor = require('unfluff');

data = extractor(my_html_data);
```

Or supply the language code yourself:

```javascript
extractor = require('unfluff', 'en');

data = extractor(my_html_data);
```

`data` will then be a json object that looks like this:

```json
{
  "title": "Shovel Knight review: rewrite history",
  "text": "Shovel Knight is inspired by the past in all the right ways — but it's far from stuck in it. [.. snip ..]",
  "tags": [],
  "canonicalLink": "http://www.polygon.com/2014/6/26/5842180/shovel-knight-review-pc-3ds-wii-u",
  "lang": "en",
  "description": "Shovel Knight is inspired by the past in all the right ways — but it's far from stuck in it.",
  "favicon": "http://cdn1.vox-cdn.com/community_logos/42931/favicon.ico"
}
```

### What is broken

- Parsing web pages in languages other than English is poorly tested and probably
  is buggy right now.
- This definitely won't work yet for languages like Chinese / Arabic / Korean /
  etc that need smarter word tokenization.
- This has only been tested on a limited set of web pages. There are probably lots
  of lurking bugs with web pages that haven't been tested yet.
