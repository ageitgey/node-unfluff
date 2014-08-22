# We use optimist for parsing the CLI arguments
fs = require('fs')
extractor = require('./unfluff')

argvParser = require('optimist')
.usage(
  'unfluff [OPTIONS] [FILE_NAME]'
).options(
  version:
    alias: 'v'
    describe: 'Show version information'
    boolean: true
  help:
    alias: 'h'
    describe: 'Show this. See: https://github.com/ageitgey/node-unfluff'
    boolean: true
  lang:
    describe: 'Override language auto-detection. Valid values are en, es, fr, etc.'
)

argv = argvParser.argv

if argv.version
  version = require('../package.json').version
  process.stdout.write "#{version}\n"
  process.exit 0

if argv.help
  argvParser.showHelp()
  process.exit 0

language = undefined
if argv.lang
  language = argv.lang

file = argv._.shift()
html = ""


if file
  html = fs.readFileSync(file).toString()
  process.stdout.write(JSON.stringify(extractor(html, language)))
else
  process.stdin.setEncoding('utf8')

  process.stdin.on 'readable', () ->
    chunk = process.stdin.read()
    if (chunk != null)
      html += chunk

  process.stdin.on 'end', () ->
    process.stdout.write(JSON.stringify(extractor(html, language)))
