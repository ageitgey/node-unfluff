default: build

BINDIR = bin
SRCDIR = src
LIBDIR = lib
TESTDIR = test
DISTDIR = dist

SRC = $(shell find "$(SRCDIR)" -name "*.coffee" -type f | sort)
LIB = $(SRC:$(SRCDIR)/%.coffee=$(LIBDIR)/%.js)
TEST = $(shell find "$(TESTDIR)" -name "*.coffee" -type f | sort)

COFFEE=node_modules/.bin/coffee --js
MOCHA=node_modules/.bin/mocha --compilers coffee:coffee-script-redux/register -r test-setup.coffee -u tdd -R dot
CJSIFY=node_modules/.bin/cjsify --minify
SEMVER=node_modules/.bin/semver

all: build test
build: $(LIB)
bundle: $(DISTDIR)/bundle.js

$(LIBDIR)/%.js: $(SRCDIR)/%.coffee
	@mkdir -p "$(@D)"
	$(COFFEE) <"$<" >"$@"

$(DISTDIR)/bundle.js: $(LIB)
	@mkdir -p "$(@D)"
	$(CJSIFY) -x ProjectName $(shell node -pe 'require("./package.json").main') >"$@"

.PHONY: phony-dep all build release-patch release-minor release-major test loc clean
phony-dep:

VERSION = $(shell node -pe 'require("./package.json").version')
release-patch: NEXT_VERSION = $(shell $(SEMVER) -i patch $(VERSION))
release-minor: NEXT_VERSION = $(shell $(SEMVER) -i minor $(VERSION))
release-major: NEXT_VERSION = $(shell $(SEMVER) -i major $(VERSION))

release-patch release-minor release-major: build test
	@printf "Current version is $(VERSION). This will publish version $(NEXT_VERSION). Press [enter] to continue." >&2
	@read nothing
	node -e "\
		var j = require('./package.json');\
		j.version = '$(NEXT_VERSION)';\
		var s = JSON.stringify(j, null, 2) + '\n';\
		require('fs').writeFileSync('./package.json', s);"
	git commit package.json -m 'Version $(NEXT_VERSION)'
	git tag -a "v$(NEXT_VERSION)" -m "Version $(NEXT_VERSION)"
	git push --tags origin HEAD:master
	npm publish

test:
	$(MOCHA) $(TEST)
$(TESTDIR)/%.coffee: phony-dep
	$(MOCHA) "$@"

loc:
	@wc -l "$(SRCDIR)"/*

clean:
	@rm -rf "$(LIBDIR)" "$(DISTDIR)"
