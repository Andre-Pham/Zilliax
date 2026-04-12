.PHONY: clean build build-release build-issues test format format-check lint lint-fix lint-analyze

# Cleans the build cache
clean:
	@set -o pipefail; \
	xcodebuild \
		-project ../Demo.xcodeproj \
		-scheme Demo \
		-sdk iphonesimulator \
		-destination 'generic/platform=iOS Simulator' \
		-configuration Debug \
		-derivedDataPath .build \
		clean 2>&1 | xcbeautify --quiet

# Builds the project and test targets
build:
	@set -o pipefail; \
	xcodebuild \
		-project ../Demo.xcodeproj \
		-scheme Demo \
		-sdk iphonesimulator \
		-destination 'generic/platform=iOS Simulator' \
		-configuration Debug \
		-derivedDataPath .build \
		build-for-testing 2>&1 | xcbeautify

# Builds the project using the release schema
build-release:
	@set -o pipefail; \
	xcodebuild \
		-project ./Lime/Lime.xcodeproj \
		-scheme Lime-Release \
		-sdk iphonesimulator \
		-destination 'generic/platform=iOS Simulator' \
		-configuration Debug \
		-derivedDataPath .build \
		build 2>&1 | xcbeautify

# Builds the project and logs any errors or warnings
build-issues:
	@set -o pipefail; \
	xcodebuild \
		-project ../Demo.xcodeproj \
		-scheme Demo \
		-sdk iphonesimulator \
		-destination 'generic/platform=iOS Simulator' \
		-configuration Debug \
		-derivedDataPath .build \
		clean build-for-testing 2>&1 | xcbeautify --quiet

# Runs tests
test:
	@set -o pipefail; \
	NSUnbufferedIO=YES xcrun xcodebuild \
		-project ../Demo.xcodeproj \
		-scheme Demo \
		-testPlan Demo \
		-sdk iphonesimulator \
		-destination 'platform=iOS Simulator,name=iPhone 17' \
		-configuration Debug \
		-derivedDataPath .build \
		-skip-testing:DemoUITests \
		test 2>&1 | xcbeautify

# Formats swift files
format:
	swiftformat . --config .swiftformat

# Checks if swift files need formatting
format-check:
	swiftformat . --config .swiftformat --lint

# Lints swift files
lint:
	swiftlint --strict --config .swiftlint.yml

# Fixes lint errors in swift files
lint-fix:
	swiftlint --fix --config .swiftlint.yml

# Lint analyzes swift files
lint-analyze:
	@set -o pipefail; \
	  trap 'rm -f swift-build.log' EXIT; \
	  xcodebuild \
		-project ../Demo.xcodeproj \
		-scheme Demo \
		-sdk iphonesimulator \
		-destination 'generic/platform=iOS Simulator' \
		clean build 2>&1 | tee swift-build.log | xcbeautify --quiet && \
	  swiftlint analyze --strict --config .swiftlint.yml --compiler-log-path swift-build.log
