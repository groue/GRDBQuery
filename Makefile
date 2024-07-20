  # If xcbeautify or xcpretty is available, use it for xcodebuild output, except in CI.
XCPRETTY =
ifeq ($(CI),true)
else
  XCBEAUTIFY_PATH := $(shell command -v xcbeautify 2> /dev/null)
  XCPRETTY_PATH := $(shell command -v xcpretty 2> /dev/null)
  ifdef XCBEAUTIFY_PATH
    XCPRETTY = | xcbeautify
  else ifdef XCPRETTY_PATH
    XCPRETTY = | xcpretty -c
  endif
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
