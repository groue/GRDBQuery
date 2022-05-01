# Configuration
DOCS_VERSION := 0.3

# Setup
DOCS_PATH := ./docs/$(DOCS_VERSION)
XCRUN := $(shell command -v xcrun)
SWIFT = $(shell $(XCRUN) --find swift 2> /dev/null)

docs:
	# https://apple.github.io/swift-docc-plugin/documentation/swiftdoccplugin/publishing-to-github-pages/
	mkdir -p $(DOCS_PATH)
	$(SWIFT) package \
	  --allow-writing-to-directory $(DOCS_PATH) \
	  generate-documentation \
	  --output-path $(DOCS_PATH) \
	  --target GRDBQuery \
	  --disable-indexing \
	  --transform-for-static-hosting \
	  --hosting-base-path GRDBQuery/$(DOCS_VERSION)

docs-main:
	mkdir -p ./docs/main
	$(SWIFT) package \
	  --allow-writing-to-directory ./docs/main \
	  generate-documentation \
	  --output-path ./docs/main \
	  --target GRDBQuery \
	  --disable-indexing \
	  --transform-for-static-hosting \
	  --hosting-base-path GRDBQuery/main

distclean:
	git -dfx .

.PHONY: distclean docs
