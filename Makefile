XCPRETTY_PATH := $(shell command -v xcpretty 2> /dev/null)
XCPRETTY = 
ifdef XCPRETTY_PATH
  XCPRETTY = | xcpretty -c
endif

test:
	swift test
	xcodebuild \
	  -project Tests/QueryTests/QueryTests.xcodeproj \
	  -scheme QueryTests \
	  -destination 'platform=macOS,arch=x86_64' \
	  clean build build-for-testing test-without-building \
	  $(XCPRETTY)

distclean:
	git clean -dffx .

.PHONY: test docs docs-localhost distclean
