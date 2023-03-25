XCPRETTY_PATH := $(shell command -v xcpretty 2> /dev/null)
XCPRETTY = 
ifdef XCPRETTY_PATH
  XCPRETTY = | xcpretty -c
endif

test:
	xcodebuild \
	  -project Tests/QueryTests/QueryTests.xcodeproj \
	  -scheme QueryTests \
	  -destination 'platform=macOS,arch=x86_64' \
	  clean build build-for-testing test-without-building \
	  $(XCPRETTY)

docs-localhost:
	# Generates documentation in ~/Sites/GRDBQuery
	# See https://discussions.apple.com/docs/DOC-3083 for Apache setup on the mac
	mkdir -p ~/Sites/GRDBQuery
	swift package \
	  --allow-writing-to-directory ~/Sites/GRDBQuery \
	  generate-documentation \
	  --output-path ~/Sites/GRDBQuery \
	  --target GRDBQuery \
	  --disable-indexing \
	  --transform-for-static-hosting \
	  --hosting-base-path "~$(USER)/GRDBQuery"
	open "http://localhost/~$(USER)/GRDBQuery/documentation/grdbquery/"

distclean:
	git clean -dffx .

.PHONY: test docs docs-localhost distclean
