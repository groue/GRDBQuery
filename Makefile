docs:
	# https://apple.github.io/swift-docc-plugin/documentation/swiftdoccplugin/publishing-to-github-pages/
	mkdir -p docs/0.1
	swift package \
	  --allow-writing-to-directory ./docs \
	  generate-documentation \
	  --output-path ./docs/0.1 \
	  --target GRDBQuery \
	  --disable-indexing \
	  --transform-for-static-hosting \
	  --hosting-base-path GRDBQuery/0.1

distclean:
	git -dfx .

.PHONY: distclean docs
